class LicensesController < ApplicationController
  before_action :session_required, :redirect_unverified_account, only: %i[create new edit update]
  before_action :set_project
  before_action :set_license, only: %i[show edit update]

  def index
    @licenses = License.active.filter_by(params[:query]).by_vanity_url.paginate(page: page_param, per_page: 30)
  end

  def new
    @license = License.new
  end

  def create
    @license = License.new(license_params)
    @license.editor_account = current_user

    if @license.save
      redirect_to @license, notice: t('.notice')
    else
      flash.now[:error] = t('.error')
      render :new
    end
  end

  def update
    if @license.update_attributes(license_params)
      redirect_to @license, notice: t('.notice')
    else
      flash.now[:error] = t('.error')
      render :edit
    end
  end

  private

  def license_params
    params.require(:license).permit(:name, :vanity_url, :url, :description, :locked)
  end

  def set_license
    @license = License.active.from_param(params[:id]).take
    raise ParamRecordNotFound unless @license
    @license.editor_account = current_user
  end

  def set_project
    @project = Project.from_param(params[:project_id]).take if params[:project_id].present?
  end
end
