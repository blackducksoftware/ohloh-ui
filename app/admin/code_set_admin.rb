ActiveAdmin.register CodeSet do
  menu false

  filter :updated_on
  filter :as_of

  actions :show, :index

  action_item :fetch, only: :show do
    link_to 'Fetch', fetch_admin_code_set_path(code_set)
  end

  action_item :reimport, only: :show do
    link_to 'Re-Import', reimport_admin_code_set_path(code_set) if code_set.clumps.exists?
  end

  action_item :resloc, only: :show do
    link_to 'Re-Sloc', resloc_admin_code_set_path(code_set) if code_set.clumps.exists?
  end

  action_item :sloc_sets, only: :show do
    link_to 'SlocSets', admin_code_set_sloc_sets_path(code_set)
  end

  index do
    %w[id as_of updated_on clump_count best_sloc_set].each { |attr| column(attr) }
    column(:sloc_set_count) { |code_set| code_set.sloc_sets.count }
    actions do |code_set|
      a link_to 'Fetch', fetch_admin_code_set_path(code_set), class: 'member_link'
      if code_set.clumps.exists?
        a link_to 'Re-Import', reimport_admin_code_set_path(code_set), class: 'member_link'
        a link_to 'Re-Sloc', resloc_admin_code_set_path(code_set), class: 'member_link'
      end
    end
  end

  member_action :fetch, method: :post do
    code_set = CodeSet.find(params[:id])
    code_set.code_location.remove_pending_jobs
    job = FetchJob.create!(code_set: code_set)
    flash[:success] = "FetchJob #{job.id} created."
    redirect_to admin_job_path(job)
  end

  member_action :reimport, method: :post do
    code_set = CodeSet.find(params[:id])
    code_set.code_location.remove_pending_jobs
    job = code_set.reimport
    flash[:success] = "CodeSet #{job.code_set_id} and ImportJob #{job.id} created."
    redirect_to admin_job_path(job)
  end

  member_action :resloc, method: :post do
    code_set = CodeSet.find(params[:id])
    code_set.code_location.remove_pending_jobs
    job = SlocJob.create(sloc_set: SlocSet.create(code_set: code_set))
    flash[:success] = "SlocJob #{job.id} created."
    redirect_to admin_job_path(job)
  end
end
