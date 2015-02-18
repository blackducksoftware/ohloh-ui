class OrganizationsController < ApplicationController
  helper ProjectsHelper
  helper RatingsHelper

  before_action :find_organization
  before_action :set_outside_committers, only: :outside_committers
  before_action :organization_context, only: :outside_committers

  def outside_projects
    @outside_projects = @organization.outside_projects((params[:page] || 1), 20)
  end

  private

  def set_outside_committers
    @outside_committers = @organization.outside_committers(params[:page], 20)
  end

  def find_organization
    @organization = Organization.from_param(params[:id]).first!
  rescue ActiveRecord::RecordNotFound
    raise ParamRecordNotFound
  end
end
