# frozen_string_literal: true

class Api::V1::JwtController < ApplicationController
  include JWTHelper
  skip_before_action :verify_authenticity_token
  before_action :get_params

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

  def get_params
    params.require(:username)
    params.require(:password)
    params[:login] = { 'login' => params[:username], 'password' => params[:password], 'remember_me' => '0' }
  end
end
