class CheckAvailabilitiesController < ApplicationController
  def account
    render json: Account.resolve_login(params[:query]).present?
  end

  def project
    render json: Project.case_insensitive_url_name(params[:query]).present?
  end

  def organization
    render json: Organization.case_insensitive_url_name(params[:query]).present?
  end

  def license
    render json: License.resolve_name(params[:query]).present?
  end
end
