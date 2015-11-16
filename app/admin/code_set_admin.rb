ActiveAdmin.register CodeSet do
  menu false

  filter :updated_on
  filter :as_of

  actions :show, :index

  action_item only: :show do
    link_to 'Fetch'
  end

  action_item only: :show do
    link_to 'Re-Import' if code_set.clumps.exists?
  end

  action_item only: :show do
    link_to 'Re-Sloc' if code_set.clumps.exists?
  end

  action_item only: :show do
    link_to 'SlocSets', admin_code_set_sloc_sets_path(code_set)
  end

  index do
    %w(id as_of updated_on clump_count).each { |attr| column(attr) }
    column :best_sloc_set
    column(:sloc_set_count) { |code_set| code_set.sloc_sets.count }
    actions do |code_set|
      a link_to 'Fetch', '#', class: 'member_link'
      if code_set.clumps.exists?
        a link_to 'Re-Import', '#', class: 'member_link'
        a link_to 'Re-Sloc', '#', class: 'member_link'
      end
    end
  end

  controller do
    def scoped_collection
      if params[:repository_id]
        Repository.find(params[:repository_id]).code_sets
      else
        super
      end
    end
  end

  member_action :fetch, method: :post do
    code_set = CodeSet.find(params[:id])
    code_set.repository.jobs.scheduled_or_failed.destroy_all
    FetchJob.create(code_set: code_set)
    redirect_to admin_repository_jobs_path(code_set.repository), flash: { success: 'FetchJob has been scheduled' }
  end
end
