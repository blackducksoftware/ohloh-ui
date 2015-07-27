class ImportJob < Job
  boolean_attr_accessor :db_intensive?, :cpu_intensive?, value: true

  def work(&block)
    code_set.import(&block)
    code_set.update(logged_at: logged_at)
  end

  def after_completed
    sloc_set = code_set.best_sloc_set || SlocSet.create(code_set_id: code_set_id)
    SlocJob.create(sloc_set_id: sloc_set.id, priority: priority + 1)
  end

  def progress_message
    I18n.t 'jobs.import_job.progress_message'
  end
end
