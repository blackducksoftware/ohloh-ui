class FetchJob < Job
  boolean_attr_accessor :disk_intensive?, :consumes_disk?, :can_have_too_long_exception?, value: true

  def progress_message
    I18n.t 'jobs.fetch_job.progress_message'
  end

  def work(&block)
    # Hack fix for all of the broken SvnRepositories that don't have a filled-in branch_name.
    # Remove this once all of the SvnRepositories are fixed.
    repository.save if repository.is_a?(SvnRepository) && repository.branch_name.nil?

    update(logged_at: code_set.fetch(&block))
  end

  # rubocop:disable Metrics/AbcSize
  def after_completed
    create_import_job && return if code_set.as_of.nil? || max_steps.to_i > 1

    # We didn't find any new code, so just pass along the timestamp of this fetch to
    # the sloc_set and analyses.
    #
    # This is an optimization to skip the ImportJob and SlocJob, so this code is a little out of place.
    code_set.update(logged_at: logged_at)
    create_sloc_job && return unless code_set.best_sloc_set

    code_set.best_sloc_set.update(logged_at: logged_at)
    create_project_analysis_job
  end
  # rubocop:enable Metrics/AbcSize

  private

  def create_import_job
    ImportJob.create(code_set_id: code_set_id, priority: priority + 1, logged_at: logged_at)
  end

  def create_sloc_job
    SlocJob.create(code_set_id: code_set_id, priority: priority + 1)
  end

  def create_project_analysis_job
    repository.projects.each do |project|
      project.ensure_job(priority + 1)
    end
  end
end
