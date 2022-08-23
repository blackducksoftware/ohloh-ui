# frozen_string_literal: true

ActiveAdmin.register Project do
  actions :index, :show

  filter :name
  filter :created_at

  controller do
    defaults finder: :find_by_vanity_url!

    def scoped_collection
      super.includes(:best_analysis).references(:best_analysis).select("*, analyses.created_at as last_analyzed")
    end
  end

  index do
    column :id
    column :name do |project|
      link_to project.name, project_path(project)
    end
    column :created_by do |project|
      link_to project.edits.first.account&.name, account_path(project.edits.first.account)
    end
    column :managers do |project|
      project.active_managers.map { |m| link_to(m.name, account_path(m)) }
    end
    column :last_analyzed, sortable: true do |project|
      project.best_analysis.try :created_at
    end
    column :created_at
    actions
  end

  member_action :create_analyze_job do
    project = Project.from_param(params[:id]).first
    ProjectAnalysisJob.incomplete.where(project_id: project.id)
                      .update_all(status: 3, do_not_retry: true, notes: 'Scheduled Another Job Manually')

    ProjectAnalysisJob.create!(project_id: project.id, notes: 'Scheduled Manually')

    redirect_to oh_admin_project_jobs_path(project),
                flash: { success: 'ProjectAnalysisJob scheduled successfully' }
  end
end
