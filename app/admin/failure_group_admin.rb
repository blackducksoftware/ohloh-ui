ActiveAdmin.register FailureGroup do
  config.sort_order = :priority_desc
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
            show_uncategorized_admin_failure_groups_path
  end

  action_item :decategorize, only: :show_uncategorized do
    link_to 'Decategorize',
            decategorize_admin_failure_group_path(params[:failure_group_id]) if params[:failure_group_id]
  end

  action_item :edit, only: :show_uncategorized do
    link_to :edit, edit_admin_failure_group_path(params[:failure_group_id]) if params[:failure_group_id]
  end

  index do
    total_categorized_jobs = number_with_delimiter(Job.categorized_failure_group.count)
    status_tag "Showing #{total_categorized_jobs} categorized jobs in #{FailureGroup.count} failure group", :ok

    column :priority
    column :name do |failure_group|
      link_to failure_group.name, edit_admin_failure_group_path(failure_group)
    end
    column :pattern
    column :auto_reschedule
    column :jobs do |failure_group|
      link_to failure_group.jobs.count, show_uncategorized_admin_failure_groups_path(failure_group_id: failure_group.id)
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
    redirect_to :back, notice: 'All failed jobs has been recategorized'
  end

  collection_action :categorize do
    FailureGroup.categorize
    redirect_to :back, notice: 'Failed jobs has been categorized'
  end

  collection_action :show_uncategorized do
    failure_group_id = params[:failure_group_id]
    @page_title = failure_group_id ? FailureGroup.find(failure_group_id).name : 'Failure Group Jobs'
    order_by = params[:order].to_s.gsub(/_asc|_desc/, '_asc' => ' asc', '_desc' => ' desc')
    order_by = order_by.blank? ? 'current_step_at desc nulls last' : ' nulls last'
    @jobs = Job.includes(:repository, :slave).order(order_by)
    @jobs = failure_group_id ? @jobs.for_failure_group(failure_group_id) : @jobs.uncategorized_failure_group
  end
end
