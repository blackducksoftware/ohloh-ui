class CodeSet < ActiveRecord::Base
  belongs_to :repository
  belongs_to :best_sloc_set, foreign_key: :best_sloc_set_id, class_name: SlocSet
  has_many :commits, -> { order(:position) }, dependent: :destroy
  has_many :clumps
  has_many :fyles, dependent: :delete_all
  has_many :sloc_sets, dependent: :destroy

  def ignore_prefixes(project)
    enlistment = project.enlistments.find_by(repository_id: repository_id)
    return CodeSet.none if enlistment.nil?
    analysis_sloc_set = enlistment.analysis_sloc_set
    analysis_sloc_set.nil? ? CodeSet.none : analysis_sloc_set.ignore_prefixes
  end

  def fetch(&block)
    logged_at = nil
    saved_max_steps = nil
    yield(0,1) if block_given?

    local_clump.open do |clump|
      logged_at = Time.now.utc
      clump.scm.pull(repository.source_scm) do |step, inner_max_step|
        # As each rev completes, do some housekeeping and progress notification
        if step > 0
          clump.timestamp!(Time.now.utc)
        end
        saved_max_steps = [saved_max_steps || 0, inner_max_step + 1].max
        yield(step, saved_max_steps) if block_given?
        clump.slave.sleep_while_busy if step < inner_max_step
      end
    end

    yield(saved_max_steps || 1, saved_max_steps || 1) if block_given?
    logged_at
  end

  def local_clump
    @local_clump ||= begin
      s = Slave.local
      clumps.find_by(slave_id: s.id) || create_clump(s)
    end
  end


  # Creates a new clump using the correct class of clump.
  # It's not totally trivial because you have to match the class that everyone else is already using.
  def create_clump(slave)
    # What is everyone else using?
    other = Clump.order('updated_at DESC').find_by(code_set_id: id)
    klass = other.class if other
    # If no one is using anything yet, then we are the first. We'll ask the repository what class to use.
    klass ||= self.repository.clump_class
    klass.create(:code_set => self, :slave => slave)
  end

  # Attempts to clean up redundant or broken clumps. All things being equal, busy slaves are cleaned up first.
  #
  # This method will delete data from disk!
  #
  # Do not call this method if other jobs are pending on this code set!
  # This method does not check against running jobs because it expects to be called WITHIN a running job.
  def balance_clumps
    (self.clumps.size - (BACKUP_CLUMPS + 1)).times do
      clump = self.clumps.find(:first, :include => :slave, :order => "COALESCE(fetched_at, '1970-01-01'), slaves.oldest_clump_timestamp")
      if clump and clump.slave.online?
        Slave.local.log_info("Load balancer deleting clump from #{clump.slave.hostname}", clump.code_set)
        clump.hard_delete
      end
    end
  end

  def import
    max_steps = 1
    current_step = 0

    if block_given?
      yield(current_step, max_steps)
    end

    self.local_clump.open(:read_only => true) do |clump|
      last_commit = self.commits.last

      opts = {}
      opts[:after] = last_commit.sha1 if last_commit

      if block_given?
        max_steps = clump.scm.commit_count(opts) + 1
      end

      # Grab the IDs of commits that are on the trunk.
      # We'll compare to this list as we iterate.
      trunk_commit_tokens = []
      if self.repository.class.dag?
        trunk_commit_tokens = clump.scm.commit_tokens(opts.merge(:trunk_only => true))
      end

      clump.scm.each_commit(opts) do |e|
        clump.slave.sleep_while_busy

        current_step += 1
        yield(current_step, max_steps) if block_given?

        name = find_or_create_name(e.author_name || e.committer_name || '[anonymous]')
        email_address = nil
        if self.repository.class.has_email_addresses?
          a = e.author_email || e.committer_email
          email_address = a && find_or_create_email_address(a)
        end

        commit = Commit.find_by_code_set_id_and_sha1(self.id, e.token.to_s)
        unless commit
          commit = Commit.new(:code_set_id => self.id,
                              :sha1 => e.token,
                              :name_id => name.id,
                              :email_address => email_address)
        end

        # Set the on_trunk flag appropriately
        if self.repository.class.dag?
          if trunk_commit_tokens.delete(commit.sha1)
            commit.on_trunk = true
          else
            commit.on_trunk = false
          end
        else
          # Linear repository -> all commits are on_trunk.
          commit.on_trunk = true
        end

        # Prefer the author date if available; fall back to commit date
        commit.time = e.author_date || e.committer_date

        # It's possible for people to lie about their checkin times, and there's not much we can do about it.
        # If the time they claim for the checkin is in the future, this will break some of our queries, so
        # as a minimum fix let's cap the checkin date to Time.now().
        #
        # In the future we might want to apply some kind of heuristic that limits a checkin time to lie between
        # the times of the checkins that precede and follow it.
        commit.time = Time.now.utc if commit.time > Time.now.utc

        commit.comment = e.message
        commit.comment = '[no comment]' unless e.message.to_s =~ /\S/
        commit.save!

        if [SvnRepository, CvsRepository].include?(self.repository.class)
          # Don't import the special Ohloh conversion files
          e.diffs.delete_if { |d| ["ohloh_token",".gitignore"].include? d.path }
        end

        cache = FyleCache.new(e, self.id)

        e.diffs.each do |d|
          fyle = cache.find_or_create(d.path)
          diff = Diff.create(
            :commit_id => commit.id,
            :fyle_id => fyle.id,
            :sha1 => d.sha1,

            # Something of a hack follows.
            # As a huge speed savings, Svn and Hg adapters do not provide SHA1 hashes of file contents.
            # However, Ohloh historically relied on these hashes to deduce the 'diff.added?' property.
            # To keep that working, we'll fill in NULL_SHA1 for the parent_sha1 in the case where the action is 'A'.
            :parent_sha1 => d.parent_sha1 || (d.action == 'A' ? NULL_SHA1 : nil),

            :deleted => (d.action == 'D')
            )
        end

        self.as_of = commit.position
        self.save!
      end
    end
    self.repository.best_code_set_id = self.id
    self.repository.save(validate: false)

    yield(max_steps, max_steps) if block_given?
    self
  end

  def name_cache() @name_cache ||= {}; end

  def find_or_create_name(name)
    n = name_cache[name]
    unless n
      begin
        n = Name.where(name: name).first_or_create
      rescue ActiveRecord::StatementInvalid
        # find_or_create is not atomic and therefore is not thread safe.
        # Another process may have created the row between our own 'find' and 'create'
        raise unless $!.message =~ /duplicate key violates unique constraint/
      end
      name_cache[name] = n
    end
    n
  end

  def find_or_create_email_address(address)
    e = email_address_cache[address]
    unless e
      begin
        e = EmailAddress.where(address: address).first_or_create
      rescue ActiveRecord::StatementInvalid
        # find_or_create is not atomic and therefore is not thread safe.
        # Another process may have created the row between our own 'find' and 'create'
        raise unless $!.message =~ /duplicate key violates unique constraint/
      end
      email_address_cache[address] = e
    end
    e
  end

  def email_address_cache() @email_address_cache ||= {}; end

  # When we run CodeSet#import we try to limit database queries
  # this is done by using this cache.
  class FyleCache
    # the limit of fyles to cache
    MAX_CACHE_SIZE = 1000

    def initialize(scm_commit, code_set_id)
      @code_set_id = code_set_id
      prefetch(scm_commit)
    end

    def prefetch(scm_commit)
      paths = scm_commit.diffs[0..MAX_CACHE_SIZE].map do |d|
        d.path
      end
      conditions = {:code_set_id => @code_set_id, :name => paths}
      @cached = Fyle.where(conditions).limit(MAX_CACHE_SIZE)
    end

    def find_or_create(path)
      @cached.find_by(name: path) || Fyle.find_or_create_by(name: path, code_set_id: @code_set_id)
    end
  end

end
