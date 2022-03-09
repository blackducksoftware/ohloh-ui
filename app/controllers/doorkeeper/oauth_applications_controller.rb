# frozen_string_literal: true

class Doorkeeper::OauthApplicationsController < ApplicationController
  before_action :session_required, :redirect_unverified_account
  before_action :set_account
  before_action :set_oauth_application
  before_action :must_own_account

  def revoke_access
    @oauth_application.access_tokens.where(resource_owner_id: @account.id).each(&:revoke)
    redirect_to_saved_path(notice: t('.success', name: @oauth_application.name))
  end

  private

  def set_account
    @account = Account.from_param(params[:account_id]).take
    raise ParamRecordNotFound unless @account
  end

  def set_oauth_application
    @oauth_application = Doorkeeper::Application.find_by(id: params[:id])
    raise ParamRecordNotFound unless @oauth_application
  end
end
