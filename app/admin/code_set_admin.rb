ActiveAdmin.register CodeSet do
  menu false

  member_action :fetch do
    code_set.repository.remove_pending_jobs
    job = FetchJob.create!(code_set: code_set)
    flash[:success] = "FetchJob #{job.id} created."
    redirect_to admin_fetch_job_path(job)
  end

  member_action :reimport do
    code_set.repository.remove_pending_jobs
    begin
      job = code_set.reimport
      flash[:success] = "CodeSet #{job.code_set_id} and ImportJob #{job.id} created."
      redirect_to admin_job_path(job)
    rescue
      flash[:error] = "ERROR: #{$!.message}"
      redirect_to :back
    end
  end

  member_action :resloc do
    code_set.repository.remove_pending_jobs
    job = SlocJob.create(sloc_set: SlocSet.create(code_set: code_set))
    flash[:success] = "SlocJob #{job.id} created."
    redirect_to admin_sloc_job_path(job)
  end
end
