# frozen_string_literal: true

class ProjectBuilder
  attr_reader :project

  def initialize(account, param_hash = {})
    @project_params = param_hash
    @editor_account = account
    create_project_from_params
  end

  def create
    create_code_location_subscription if @project.save && @project.enlistments.exists?
    @project
  end

  private

  def create_project_from_params
    @project = Project.new({ editor_account: @editor_account }.merge(@project_params))
    set_associations
  end

  def create_code_location_subscription
    CodeLocationSubscription.create(code_location_id: @project.enlistments.last.code_location_id,
                                    client_relation_id: @project.id)
  end

  def set_associations
    @project.assign_editor_account_to_associations
    @project.manages.new(account: @editor_account) if @project_params[:managed_by_creator].to_bool
  end
end
