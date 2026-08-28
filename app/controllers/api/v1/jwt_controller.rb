# frozen_string_literal: true

class Api::V1::JwtController < ApplicationController
  include JwtHelper
  skip_before_action :verify_authenticity_token
  before_action :get_params, only: :create

  def create
    params[:login] = { 'login' => params[:username], 'password' => params[:password], 'remember_me' => '0' }
    account = authenticate(params)

    if account
      jwt = build_jwt(account.login)
      render json: jwt, status: :ok
    else
      render json: 'Not Authorized', status: :unauthorized
    end
  end

  def destroy
    # Extract JWT from Authorization header (format: "Bearer <token>")
    auth_header = request.headers['Authorization']
    if auth_header&.start_with?('Bearer ')
      jwt_token = auth_header.sub('Bearer ', '')
      account = decode_jwt(jwt_token)
      # Check if decoding was successful (not an error string)
      Rails.logger.info("User #{account.login} logged out successfully") unless account.is_a?(String)
    end
    render json: { message: 'Logout successful' }, status: :ok
  end

  def get_params
    begin
      params.require(:username)
      params.require(:password)
    rescue ActionController::ParameterMissing
      render json: 'Bad Request', status: :bad_request
    end
    params[:login] = { 'login' => params[:username], 'password' => params[:password], 'remember_me' => '0' }
  end
end
