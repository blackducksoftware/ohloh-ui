# frozen_string_literal: true

class Api::V1::ProjectsController < ApplicationController
  include JWTHelper
  include ProjectsHelper

  skip_before_action :verify_authenticity_token
  before_action :authenticate_jwt

  def create
    @project = build_project

    if @project.save
      create_code_location_subscription if @project.enlistments.exists?
      render json: @project.id, status: :created
    else
      render json: @project.errors.messages.to_json, status: :bad_request
    end
  end

  private

  def project_params
    params.permit(:name, :vanity_url, :homepage_url, :repo_url, :coverity_project_id, :license_name)
  end

  def build_project
    project = populate_project_from_forge(project_params[:repo_url], true) || Project.new
    create_params(project) if project
    ProjectBuilder.new(current_user, @project_params || {}).project
  end

  def create_params(project)
    project.name = params[:name] if params[:name]
    project.vanity_url = params[:vanity_url] if params[:vanity_url]
    project.coverity_project_id = params[:coverity_project_id]
    assign_enlistments_attributes(project)
    assign_license_attributes
  end

  def assign_enlistments_attributes(project)
    code_location = project.code_location_object
    code_location_attributes = { 'scm_type' => code_location&.scm_type || 'git',
                                 'url' => code_location&.url || project_params[:repo_url],
                                 'branch' => code_location&.branch || code_location_branch(project_params[:repo_url]) }
    enlistments_attributes = [{ 'code_location_attributes' => code_location_attributes }]
    @project_params = project.as_json.deep_merge(enlistments_attributes: enlistments_attributes)
  end

  def assign_license_attributes
    project_license = License.find_by_name(params[:license_name])&.id
    return unless project_license

    @project_params = @project_params.as_json.deep_merge(project_licenses_attributes:
                                                           [{ 'license_id' => project_license }])
  end

  def create_code_location_subscription
    CodeLocationSubscription.create(code_location_id: @project.enlistments.last.code_location_id,
                                    client_relation_id: @project.id)
  end

  def code_location_branch(url)
    out, _err, _status = Open3.capture3("git ls-remote --symref #{url} HEAD | head -1 | awk '{print $2}'")
    out.strip.sub(/refs\/heads\//, '')
  end
end
