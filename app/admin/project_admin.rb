# frozen_string_literal: true

ActiveAdmin.register Project do
  actions :index, :show

  filter :name
  filter :last_analyzed, as: :date_range, label: 'Last Analyzed Range'
  filter :has_active_enlistments, as: :boolean, label: 'Show only Active Enlisted'
  filter :created_at
  filter :is_important, as: :boolean, label: 'Show only Important Project'

  controller do
    defaults finder: :find_by_vanity_url!

    before_action only: :index do
      if params['commit'].blank?
        default_params = { has_active_enlistments: true }
        params['q'] ||= {}
        params['q'].merge! default_params

        request.query_parameters.merge! default_params
      end
    end

    def scoped_collection
      projects = params[:active] == 'true' ? super.active : super
      projects.includes(:best_analysis).references(:best_analysis)
    end

    def apply_filtering(chain)
      @search = chain.ransack(params[:q] || {})
      @search.result(distinct: true)
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
    column :last_analyzed, sortable: 'analyses.created_at' do |project|
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
