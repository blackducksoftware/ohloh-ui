# frozen_string_literal: true

ActiveAdmin.register FailureGroup do
  menu false
  config.sort_order = :priority_desc
  permit_params :name, :pattern, :priority, :auto_reschedule
  filter :name
  filter :pattern
  filter :auto_reschedule

  action_item :categorize, only: :index do
    link_to 'Categorize', categorize_admin_failure_groups_path
  end

  action_item :recategorize, only: :index do
    link_to 'Recategorize', recategorize_admin_failure_groups_path,
            data: { confirm: 'This will re-categorize all jobs. Are you sure you want to continue?' }
  end

  action_item :uncategorized_jobs, only: :index do
    jobs_count = Job.uncategorized_failure_group.count
    link_to "#{number_with_delimiter jobs_count} uncategorized failed jobs",
            admin_jobs_path(scope: 'uncategorized_failed_jobs')
  end

  action_item :decategorize, only: :show do
    link_to 'Decategorize',
            decategorize_admin_failure_group_path(params[:id])
  end

  index do
    total_categorized_jobs = number_with_delimiter(Job.categorized_failure_group.count)
    status_tag "Showing #{total_categorized_jobs} categorized jobs in #{FailureGroup.count} failure group", class: 'ok'

    column :priority
    column :name do |failure_group|
      link_to failure_group.name, edit_admin_failure_group_path(failure_group)
    end
    column :pattern
    column :auto_reschedule
    column :job_count, sortable: :job_count do |failure_group|
      link_to failure_group.jobs.count, admin_failure_group_jobs_path(failure_group)
    end
    actions
  end

  member_action :decategorize do
    failure_group = FailureGroup.find(params[:id])
    failure_group.decategorize
    redirect_to admin_failure_groups_path, notice: "FailureGroup #{failure_group.name}'s jobs has been decategorized"
  end

  collection_action :recategorize do
    FailureGroup.recategorize
    redirect_to_saved_path(notice: 'All failed jobs were successfully recategorized')
  end

  collection_action :categorize do
    FailureGroup.categorize
    redirect_to_saved_path(notice: 'Failed jobs were successfully categorized')
  end

  controller do
    def destroy
      failure_group = FailureGroup.find(params[:id])
      failure_group.decategorize
      failure_group.destroy
      redirect_to admin_failure_groups_path, notice: I18n.t('admin.failure_group.deleted')
    end

    def scoped_collection
      super
        .select('failure_groups.*, 0 as job_count')
    end
  end
end
