# frozen_string_literal: true

class Api::V1::JwtController < ApplicationController
  include JwtHelper
  include JwtLoginLockout
  skip_before_action :verify_authenticity_token
  before_action :get_params

  def create
    account = Account.fetch_by_login_or_email(params[:username])

    return render json: 'Not Authorized', status: :unauthorized if jwt_locked?(account)

    authenticate_and_respond(account)
  end

  private

  def authenticate_and_respond(account)
    if account&.authenticated?(params[:password])
      handle_jwt_auth_success(account)
      render json: build_jwt(account.login), status: :ok
    else
      handle_jwt_auth_failure(account)
      render json: 'Not Authorized', status: :unauthorized
    end
  end

  def get_params
    params.require(:username)
    params.require(:password)
  rescue ActionController::ParameterMissing
    render json: 'Bad Request', status: :bad_request
  end
end
