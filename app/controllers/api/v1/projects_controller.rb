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
    project = populate_project_from_forge(project_params[:repo_url], true)
    if project
      project.name = params[:name] if params[:name]
      project.coverity_project_id = params[:coverity_project_id]
      create_params(project)
    end
    ProjectBuilder.new(current_user, @project_params || {}).project
  end

  def create_params(project)
    enlistments_attributes = [{ 'code_location_attributes' => { 'scm_type' => project.code_location_object.scm_type \
                                                                              || 'git',
                                                                'url' => project.code_location_object.url,
                                                                'branch' => project.code_location_object.branch \
                                                                          || 'main' } }]
    @project_params = project.as_json.deep_merge(enlistments_attributes: enlistments_attributes)
    project_license = License.find_by_name(params[:license_name])&.id
    return unless project_license

    @project_params = @project_params.as_json.deep_merge(project_licenses_attributes: [{ 'license_id' =>
                                                                                            project_license }])
  end

  def create_code_location_subscription
    CodeLocationSubscription.create(code_location_id: @project.enlistments.last.code_location_id,
                                    client_relation_id: @project.id)
  end
end
