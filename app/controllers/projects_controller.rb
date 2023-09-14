# frozen_string_literal: true

class ProjectsController < ApplicationController
  [AnalysesHelper, FactoidsHelper, MapHelper, RatingsHelper,
   ScmHelper, TagsHelper].each { |help| helper help }

  layout 'responsive_project_layout', only: %i[show badges]

  include ProjectFilters
  include ProjectsHelper

  def index
    render template: @account ? 'projects/index_managed' : 'projects/index' if request_format == 'html'
  end

  def show
    render 'projects/no_analysis' if request.format.xml? && @analysis.blank?
  end

  def users
    @accounts = @project.users(params[:query], params[:sort])
    @accounts = @accounts.paginate(page: page_param, per_page: 10, total_entries: @accounts.length)
  end

  def update
    return render_unauthorized unless @project.edit_authorized?

    if @project.update(project_params)
      redirect_to project_path(@project), notice: t('.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def create
    create_project_from_params
    if @project.save
      create_code_location_subscription if @project.enlistments.exists?
      redirect_to project_path(@project)
    else
      @project.code_location_object = @project.enlistments.last.try(:code_location)
      flash.now[:error] = t('.failure')
      render :check_forge, status: :unprocessable_entity
    end
  end

  def check_forge
    if @projects.blank? || params[:bypass]
      @project = populate_project_from_forge(params[:codelocation], false)
      @project = @project.is_a?(ActiveRecord::Base) ? @project : nil
    else
      flash.now[:notice] = @projects.length == 1 ? t('.code_location_single') : t('.code_location_multiple')
      render template: 'projects/check_forge_duplicate'
    end
  end

  def similar_by_tags
    return render_404 unless request.xhr?

    respond_to do |format|
      format.js
    end
  end

  def similar
    @similar_by_tags = @project.related_by_tags.limit(10)
    @similar_by_stacks = @project.related_by_stacks(10)
  end

  def report_outdated
    if @project.reported_at.blank?
      @project.update!(reported_at: Time.current, editor_account: Account.hamster)
      ProjectMailer.report_outdated(current_user, @project).deliver
    end
    flash[:notice] = t('.notification')
    redirect_back(fallback_location: root_path)
  end

  private

  def project_params
    params.require(:project).permit(
      :name, :description, :vanity_url, :url, :download_url, :managed_by_creator,
      project_licenses_attributes: [:license_id],
      enlistments_attributes: [code_location_attributes: %i[branch url scm_type]]
    )
  end

  def create_project_from_params
    @project = ProjectBuilder.new(current_user, project_params).create
  end

  def create_code_location_subscription
    CodeLocationSubscription.create(code_location_id: @project.enlistments.last.code_location_id,
                                    client_relation_id: @project.id)
  end
end
