class OrganizationsController < ApplicationController
  helper ProjectsHelper
  helper RatingsHelper
  helper OrganizationsHelper

  before_action :find_organization
  before_action :organization_context, only: [:outside_projects, :projects, :outside_committers]
  before_action :set_outside_committers, only: :outside_committers

  def outside_projects
    @outside_projects = @organization.outside_projects(params[:page], 20)
  end

  def projects
    @affiliated_projects = @organization.affiliated_projects(params[:page], 20)
  end

  private

  def set_outside_committers
    @outside_committers = @organization.outside_committers(params[:page], 20)
  end

  def find_organization
    @organization = Organization.from_param(params[:id]).take
    fail ParamRecordNotFound if @organization.nil?
  end
end
