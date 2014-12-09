class PermissionsController < ApplicationController
  before_action :find_model
  before_filter :show_permissions_alert, only: :show

  def show
  end

  def update
  end

  private

  def find_model
    @model = current_project.permission || Permission.new(target: current_project)
  end

  def show_permissions_alert
    #return if current_user_can_manage?
    flash.now[:notice] = current_user ? t('permissions.not_manager') : t('permissions.must_log_in')
  end
end
