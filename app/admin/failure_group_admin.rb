ActiveAdmin.register FailureGroup do
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
            show_uncategorized_admin_failure_groups_path
  end

  action_item :decategorize, only: [:show, :jobs] do
    link_to 'Decategorize',
            decategorize_admin_failure_group_path(params[:id])
  end

  action_item :edit, only: :jobs do
    link_to :edit, edit_admin_failure_group_path(params[:id])
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
      link_to failure_group.jobs.count, jobs_admin_failure_group_path(failure_group)
    end
    actions
  end

  member_action :decategorize do
    failure_group = FailureGroup.find(params[:id])
    failure_group.decategorize
    redirect_to admin_failure_groups_path, notice: "FailureGroup #{failure_group.name}'s jobs has been decategorized"
  end

  member_action :jobs do
    failure_group = FailureGroup.find(params[:id])
    @page_title = failure_group.name

    @jobs = failure_group.jobs.includes(:repository, :slave).failed.with_exception.order(order_by)

    render 'show_uncategorized'
  end

  collection_action :recategorize do
    FailureGroup.recategorize
    redirect_to :back, notice: 'All failed jobs were successfully recategorized'
  end

  collection_action :categorize do
    FailureGroup.categorize
    redirect_to :back, notice: 'Failed jobs were successfully categorized'
  end

  collection_action :show_uncategorized do
    @page_title = 'Failure Group Jobs'

    @jobs = Job.includes(:repository, :slave).uncategorized_failure_group.order(order_by)
  end

  controller do
    def destroy
      failure_group = FailureGroup.find(params[:id])
      failure_group.decategorize
      failure_group.destroy
      redirect_to admin_failure_groups_path, notice: 'FailureGroup was successfully deleted'
    end

    private

    def order_by
      sort_param = params[:order].to_s.gsub(/_(asc|desc)/, ' \1')
      sort_param.blank? ? 'current_step_at desc nulls last' : "#{sort_param} nulls last"
    end
  end
end
