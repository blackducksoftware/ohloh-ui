class FetchJob < Job
  def progress_message
    I18n.t 'jobs.fetch_job.progress_message'
  end

  def work(&block)
    # HACK FIX for all of the broken SvnRepositories that don't have a filled-in branch_name.
    # Remove this once all of the SvnRepositories are fixed.
    if self.repository.is_a?(SvnRepository)
      self.repository.save unless self.repository.branch_name
    end

    self.update_attributes(:logged_at => self.code_set.fetch(&block))
  end

  def self.disk_intensive?() true; end
  def self.consumes_disk?()  true; end

  def after_completed
    # We should have a better way to detect that the fetch job actually did work than simply checking the max_step count
    if self.code_set.as_of.nil? or max_steps > 1
      # We fetched new code. Schedule an import.
      ImportJob.create(:code_set_id => self.code_set_id, :priority => self.priority + 1, :logged_at => self.logged_at)
    else
      # We didn't find any new code, so just pass along the timestamp of this fetch to
      # the sloc_set and analyses.
      #
      # This is an optimization to skip the ImportJob and SlocJob, so this code is a little out of place.
      self.code_set.update_attributes(:logged_at => self.logged_at)
      if self.code_set.best_sloc_set
        self.code_set.best_sloc_set.update_attributes(:logged_at => self.logged_at)
        # Give the analysis a chance to recalc or simply update its timestamp
        self.repository.projects.each do |p|
          p.ensure_job(self.priority + 1)
        end
      else
        SlocJob.create(:code_set_id => self.code_set_id, :priority => self.priority + 1)
      end
    end
  end
end
