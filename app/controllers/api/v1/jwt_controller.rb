# frozen_string_literal: true

class Api::V1::JwtController < ApplicationController
  include JWTHelper
  skip_before_action :verify_authenticity_token

  def create
    params.require(:username)
    params.require(:password)
    params[:login] = { 'login' => params[:username], 'password' => params[:password], 'remember_me' => '0' }

    account_or_nil = authenticate(params)

    sign_in(account_or_nil) do |status|
      if status.success?
        jwt = build_jwt(params[:username])
        render json: jwt, status: :ok
      else
        render json: 'Not Authorized', status: :unauthorized
      end
    end
  end
end
