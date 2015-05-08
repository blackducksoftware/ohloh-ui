class CheckAvailabilitiesController < ApplicationController
  # NOTE: Replaces accounts#resolve_login.
  def account
    render json: Account.resolve_login(params[:query]).present?
  end

  # NOTE: Replaces projects#resolve_url_name.
  def project
    render json: Project.case_insensitive_url_name(params[:query]).present?
  end

  # NOTE: Replaces organizations#resolve_url_name.
  def organization
    render json: Organization.case_insensitive_url_name(params[:query]).present?
  end

  def license
    render json: License.resolve_name(params[:query]).present?
  end
end
