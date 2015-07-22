class ImportJob < Job
  def self.db_intensive?()   true; end
  def self.cpu_intensive?()  true; end

  def work(&block)
    self.code_set.import &block
    self.code_set.update_attributes(:logged_at => self.logged_at)
  end

  def after_completed
    if self.code_set.best_sloc_set
      SlocJob.create(:sloc_set_id => self.code_set.best_sloc_set_id, :priority => self.priority + 1)
    else
      ss = SlocSet.create(:code_set_id => self.code_set_id)
      SlocJob.create(:sloc_set_id => ss.id, :priority => self.priority + 1)
    end
  end

  def progress_message
    I18n.t 'jobs.import_job.progress_message'
  end
end
