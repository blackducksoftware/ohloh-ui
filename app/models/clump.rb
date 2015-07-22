class Clump < ActiveRecord::Base
  belongs_to :slave
  belongs_to :code_set

  def scm_class
    OhlohScm::Adapters::GitAdapter
  end

  def path
    self.slave.path_from_code_set_id(self.code_set_id)
  end

  def branch_name
    self.code_set.repository.branch_name
  end

  def scm
    @scm ||= scm_class.new(:url => self.url, :branch_name => branch_name).normalize
  end

  # Ensures that there is a local disk store containing the latest code.
  # One will be created if it does not already exist.
  # The local disk will be updated with the latest changes from all slaves.
  #
  # When the block completes, any local changes will be backed up on at
  # least one other slave. If the changes can't be backed up, an exception will be thrown.
  #
  # You may pass :read_only => true as an optional parameter, which will suppress
  # the final backup. Specify this option if you do not intend to make any changes.
  #
  # A username and password can be passed in cases where the remote repository
  # requires them (that is, when initializing svnsync against a secured repository).
  def open(opts={})
    self.pull_all
    yield self if block_given?
    self.push_one unless opts[:read_only]
    self.scm.clean_up_disk if self.scm.respond_to? :clean_up_disk
    self.code_set.balance_clumps
  end

  # Clone this clump on a new slave, then hard delete this clump.
  # Effectively moves a clump from one slave to another.
  # Primarily intended for load balancing/disk space resolution.
  #
  # Returns the new clump, or nil if could not be moved.
  def move_to(slave)
    raise 'move_to() can only be used for local clumps' unless self.slave == Slave.local
    clump = try_push_to_new_slave(slave)
    return nil unless clump
    self.hard_delete
    clump
  end

  # Pulls from every other clump with a greater 'fetched_at' timestamp
  # to make sure that the local clump is up-to-date.
  #
  # Clumps without timestamps are pulled as well, since we can't know up front whether
  # the clump is newer or older. A clump should only be missing a timestamp if
  # it is brand new or has been discovered on disk by the script/slave daemon.
  #
  # If no other clumps exists, the local repository is unmodified.
  #
  # This method may wait indefinitely for a machine that is too busy for git operations.
  #
  # If a pull is attempted and fails, an exception will be raised.
  #
  # NOTE: readable_clumps calls other_clumps, which uses COALESCE to ensure fetched_at
  # is never nil; it uses '1970-01-01' (line 262)
  def pull_all
    self.readable_clumps.each do |clump|
      logged_pull_from(clump) if !self.scm.exists? or self.fetched_at.nil? or
        clump.fetched_at.nil? or clump.fetched_at > self.fetched_at
    end
  end

  # Quickly push our local changes to one other slave.
  # If no other clumps exist, create one.
  # If we can't push at least one copy somewhere, throw an exception.
  #
  # This method may wait indefinitely for a machine that is too busy for git operations.
  def push_one
    return if BACKUP_CLUMPS == 0 # Don't push if backups are turned off.

    # Attempt to push to the most recent backup copy. This maximizes the odds that the
    # push will be a quick one, with the fewest deltas.
    clumps = self.writeable_clumps
    if clumps.any?
      # First, try to push to a slave that isn't too busy
      clumps.reject { |c| c.slave.too_busy_for_git? }.each do |clump|
        return if try_push_to_existing_clump(clump)
      end
      # If we couldn't push, try pushing to the busy slaves, which implies we'll be doing some waiting around.
      clumps.reject { |c| !c.slave.too_busy_for_git? }.each do |clump|
        return if try_push_to_existing_clump(clump)
      end
    end
    self.slave.log_warning("CodeSet #{self.code_set.id} could not be pushed to any existing clump.", self.code_set)

    # We couldn't push to any existing clump. Try to create a new clump somewhere.
    slaves = self.slave.eligible_target_slaves(self.code_set_id)
    if slaves.any?
      # First, try to push to a slave that isn't too busy
      slaves.reject { |s| s.too_busy_for_git? }.each do |slave|
        return if try_push_to_new_slave(slave)
      end
      # If we couldn't push, try pushing to the busy slaves, which implies we'll be doing some waiting around.
      slaves.reject { |s| !s.too_busy_for_git? }.each do |slave|
        return if try_push_to_new_slave(slave)
      end
    end

    # If after trying all of this we still couldn't push anywhere, we throw an exception.
    raise RuntimeError.new( "CodeSet #{self.code_set_id} could not be pushed." )
  end

  # Push our local changes to every existing clump.
  # If there are insufficient backup clumps, make one new clump as well.
  # If we can't push at least one copy somewhere, throw an exception.
  #
  # This method may wait indefinitely for a slave that is too busy for git operations.
  def push_all
    return if BACKUP_CLUMPS == 0 # Don't push if backups are turned off.

    success_count = 0

    # Attempt to push to all existing clumps.
    self.writeable_clumps.each do |clump|
      success_count += 1 if try_push_to_existing_clump(clump)
    end
    self.slave.log_warning("CodeSet #{self.code_set.id} could not be pushed to any existing clump.", self.code_set) if success_count < 1

    # If we haven't pushed anywhere yet, or if there are not enough backup clumps, push to a new clump
    if (self.code_set.clumps.size < BACKUP_CLUMPS + 1) or (success_count < 1)
      targets = self.slave.eligible_target_slaves(self.code_set_id)
      if targets.any?
        targets.each do |slave|
          if try_push_to_new_slave(slave)
            success_count += 1
            break if success_count >= BACKUP_CLUMPS
          end
        end
        self.slave.log_warning("CodeSet #{self.code_set.id} has only #{self.code_set.clumps.size} copies, and a new clump could not be created.", self.code_set)
      else
        self.slave.log_warning("CodeSet #{self.code_set.id} has only #{self.code_set.clumps.size} copies, but there are no eligible slaves to receive a new clump.", self.code_set)
      end
    end

    # If after trying all of this we still could not push anywhere, we throw an exception.
    raise RuntimeError.new( "CodeSet #{self.code_set_id} could not be pushed." ) if success_count < 1
  end

  # Tries to push to the specified clump.
  # If there is a failure, exceptions are caught and logged, and nil is returned.
  #
  # This method may wait indefinitely for a machine that is too busy for git operations.
  def try_push_to_existing_clump(clump)
    begin
      logged_push_to(clump)
      return clump
    rescue
      nil
    end
  end

  # Tries to create and push to a new clump on the given slave.
  # If there is a failure, exceptions are caught and logged, and nil is returned.
  #
  # This method may wait indefinitely for a machine that is too busy for git operations.
  def try_push_to_new_slave(slave)
    return unless slave
    begin
      clump = logged_push_to(self.class.new(:code_set_id => self.code_set_id, :slave => slave))
      if clump
        self.slave.log_info "Created new Clump #{clump.id} for CodeSet #{clump.code_set_id} on #{slave.hostname}.", self.code_set
        return clump
      end
    rescue
      self.slave.log_error "CodeSet #{self.code_set_id} failed push to #{slave.hostname}:\n#{$!}", self.code_set
      Clump.delete(clump) if clump
    end
    nil
  end

  # Pulls, then logs success or exception. Exceptions are rethrown.
  #
  # This method may wait indefinitely for a machine that is too busy for git operations.
  def logged_pull_from(clump)
    begin
      if clump.slave.offline?
        self.slave.log_error "CodeSet #{self.code_set} cannot be pulled from offline slave #{clump.slave.hostname}."
        return nil
      end
      unless clump.scm.exists?
        self.slave.log_error "CodeSet #{self.code_set} cannot be pulled from #{clump.slave.hostname} -- clump does not exist."
        return nil
      end
      pause_while_too_busy(clump)
      pull(clump)
      self.timestamp!(clump.fetched_at)
      self.slave.log_debug "CodeSet #{self.code_set_id} pulled from #{clump.slave.hostname}", self.code_set
      return clump
    rescue
      self.slave.log_error "CodeSet #{self.code_set_id} pull failed from #{clump.slave.hostname}:\n#{$!}", self.code_set
      raise
    end
  end

  def pull(clump)
    logger.warn { "Pulling #{self.code_set_id} from #{clump.slave.hostname}:#{clump.path}" }
    self.scm.pull(clump.scm)
  end

  # Pushes, then logs success or exception. Exceptions are rethrown.
  #
  # This method may wait indefinitely for a machine that is too busy for git operations.
  def logged_push_to(clump)
    begin
      if clump.slave.read_only?
        self.slave.log_error "CodeSet #{self.code_set} cannot be pushed to read-only slave #{clump.slave.hostname}."
        return nil
      end
      if clump.slave.offline?
        self.slave.log_error "CodeSet #{self.code_set} cannot be pushed to offline slave #{clump.slave.hostname}."
        return nil
      end
      pause_while_too_busy(clump)
      push(clump)
      clump.save!
      clump.timestamp!(self.fetched_at)
      self.slave.log_debug "CodeSet #{self.code_set_id} pushed to #{clump.slave.hostname}", self.code_set
      return clump
    rescue
      self.slave.log_error "CodeSet #{self.code_set_id} failed push to #{clump.slave.hostname}: #{$!}", self.code_set
      raise
    end
  end

  def push(clump)
    logger.warn { "Pushing code set #{self.code_set_id} to #{clump.slave.hostname}:#{clump.path}" }
    self.scm.push(clump.scm)
  end

  # Advance the timestamp to the passed value.
  # If the passed value is older than the current value, nothing happens.
  def timestamp!(newtime)
    if newtime
      self.update_attribute(:fetched_at, newtime) unless self.fetched_at && self.fetched_at > newtime
    end
    self.fetched_at
  end

  def pause_while_too_busy(clump)
    while clump.slave.reload.too_busy_for_git?
      self.slave.log_warning("Remote slave #{clump.slave.hostname} is too busy for pull. Sleeping.", clump.code_set)
      sleep 30
    end
  end

  # Where can I push?
  def other_clumps(mode="RW")
    if self.code_set
      self.code_set.clumps.includes(:slave).where("slave_id!=? AND UPPER(slaves.clump_status) LIKE '%#{mode}%'", self.slave_id)
          .order("COALESCE(clumps.fetched_at, '1970-01-01') DESC").references(:all)
    else
      []
    end
  end

  def writeable_clumps
    other_clumps("W")
  end

  def readable_clumps
    other_clumps("R")
  end

  # Deletes the clump from disk as well as from the database.
  # If a job is running on this clump, does nothing and returns false.
  def hard_delete
    return false if self.slave.jobs.find_by(code_set_id: code_set_id, status: Job::STATUS_RUNNING)

    Clump.delete(self.id)
    self.slave.run_local_or_remote("rm -rf #{self.path}")
    Clump.delete(self.id) # In the odd case that the clump got re-added while we were deleting from disk. Slave daemon might do this.
    self.slave.log_info "CodeSet #{self.code_set_id} deleted from #{self.slave.hostname}", self.code_set
    true
  end
end
