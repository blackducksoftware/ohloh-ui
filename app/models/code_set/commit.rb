class CodeSet::Commit
  def initialize(code_set, scm_commit)
    @code_set = code_set
    @scm_commit = scm_commit
  end

  def find_or_create
    @commit = find || build
    update_on_trunk
    update_time
    update_comment
    @commit.save!
  end

  private

  def find
    Commit.find_by(code_set_id: @code_set.id, sha1: @scm_commit.token.to_s)
  end

  def build
    name = find_or_create_name
    email_address = find_or_create_email_address
    Commit.new(code_set_id: @code_set.id, sha1: @scm_commit.token, name_id: name.id, email_address: email_address)
  end

  def update_on_trunk
    @commit.on_trunk = repository.class.dag?
    @commit.on_trunk ||= trunk_commit_tokens.delete(@scm_commit.sha1).to_bool
  end

  def update_time
    @commit.time = @scm_commit.author_date || @scm_commit.committer_date

    # It's possible for people to lie about their checkin times, and there's not much we can do about it.
    # If the time they claim for the checkin is in the future, this will break some of our queries, so
    # as a minimum fix let's cap the checkin date to Time.now().
    #
    # In the future we might want to apply some kind of heuristic that limits a checkin time to lie between
    # the times of the checkins that precede and follow it.
    @commit.time = Time.now.utc if @commit.time > Time.now.utc
  end

  def update_comment
    @commit.comment = @scm_commit.message
    @commit.comment = DEFAULT_COMMIT_COMMENT unless @scm_commit.message.to_s =~ /\S/
  end

  def find_or_create_name
    name = @scm_commit.author_name || @scm_commit.committer_name || '[anonymous]'

    @name_cache ||= {}
    @name_cache[name] ||= Name.where(name: name).first_or_create
  end

  def find_or_create_email_address
    return unless repository.class.has_email_addresses?

    email = @scm_commit.author_email || @scm_commit.committer_email
    return unless email

    @email_address_cache ||= {}
    @email_address_cache[address] ||= EmailAddress.where(address: address).first_or_create
  end

  def trunk_commit_tokens
    return @trunk_commit_tokens if @trunk_commit_tokens
    return [] unless @code_set.repository.class.dag?

    @code_set.clump.scm.commit_tokens(@options.merge(trunk_only: true))
  end
end
