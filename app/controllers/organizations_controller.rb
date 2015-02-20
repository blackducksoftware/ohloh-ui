class OrganizationsController < ApplicationController
  helper ProjectsHelper
  helper RatingsHelper

  before_action :find_organization

  def show
    @graphics = OrgInfoGraphics.new(@organization)
  end

  def outside_projects
    @outside_projects = @organization.outside_projects((params[:page] || 1), 20)
  end

  private

  def find_organization
    @organization = Organization.from_param(params[:id]).first!
  rescue ActiveRecord::RecordNotFound
    raise ParamRecordNotFound
  end
end
