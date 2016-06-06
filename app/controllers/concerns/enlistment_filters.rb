module EnlistmentFilters
  extend ActiveSupport::Concern

  included do
    before_action :session_required, :redirect_unverified_account, only: [:create, :new, :destroy, :edit, :update]
    before_action :set_project_or_fail
    before_action :set_project_editor_account_to_current_user
    before_action :find_enlistment, only: [:show, :edit, :update, :destroy]
    before_action :project_context, only: [:index, :new, :edit, :create, :update]
  end

  private

  def find_enlistment
    @enlistment = Enlistment.find_by(id: params[:id])
    raise ParamRecordNotFound if @enlistment.nil?
    @enlistment.editor_account = current_user
  end
end
