class OrganizationsController < ApplicationController
  helper ProjectsHelper
  helper RatingsHelper
  helper OrganizationsHelper

  before_action :find_organization
  before_action :organization_context, except: [:print_infographic]
  before_action :set_outside_committers, only: :outside_committers

  def show
    @graphics = OrgInfoGraphics.new(@organization)
  end

  def outside_projects
    @outside_projects = @organization.outside_projects(params[:page], 20)
  end

  def projects
    @affiliated_projects = @organization.affiliated_projects(params[:page], 20)
  end

  def print_infographic
    render layout: false
  end

  def affiliated_committers
    @affiliated_committers = @organization.affiliated_committers((params[:page] || 1), 20)
    @stats_map = Account::CommitCore.new(@affiliated_committers.map(&:id)).most_and_recent_data
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
