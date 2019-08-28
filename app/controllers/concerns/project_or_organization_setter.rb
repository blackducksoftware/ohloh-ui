# frozen_string_literal: true

module ProjectOrOrganizationSetter
  extend ActiveSupport::Concern

  included do
    before_action :set_project, if: :projects_route?
    before_action :set_organization, if: :organizations_route?
    before_action :fail_unless_parent

    private

    def set_project
      @parent = @project = Project.by_vanity_url_or_id(params[:id]).take
      project_context && render('projects/deleted') if @project.try(:deleted?)
    end

    def set_organization
      @parent = @organization = Organization.from_param(params[:id]).take
    end

    def fail_unless_parent
      raise ParamRecordNotFound unless @parent
    end

    def projects_route?
      request.path.match(/\A\/p\//).present?
    end

    def organizations_route?
      request.path.match(/\A\/orgs\//).present?
    end
  end
end
