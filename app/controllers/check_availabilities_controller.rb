class CheckAvailabilitiesController < ApplicationController
  # NOTE: Replaces accounts#resolve_login.
  def account
    render json: Account.resolve_login(params[:query]).present?
  end
end
