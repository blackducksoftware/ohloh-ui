# frozen_string_literal: true

class CheckAvailabilitiesController < ApplicationController
  before_action :handle_blank_query_param

  def account
    render json: Account.resolve_login(params[:query]).present?
  end

  def project
    render json: Project.case_insensitive_vanity_url(params[:query]).present?
  end

  def organization
    render json: Organization.case_insensitive_vanity_url(params[:query]).present?
  end

  def license
    render json: License.active.resolve_vanity_url(params[:query]).present?
  end

  private

  def handle_blank_query_param
    render(json: false) if params[:query].blank?
  end
end
