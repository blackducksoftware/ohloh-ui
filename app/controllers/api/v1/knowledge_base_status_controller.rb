# frozen_string_literal: true

class Api::V1::KnowledgeBaseStatusController < ApplicationController
  include JWTHelper

  skip_before_action :verify_authenticity_token
  before_action :authenticate_jwt

  def sync
    conn = KnowledgeBaseQueue.connect
    exchange = KnowledgeBaseQueue.get_exchange(conn)
    display_kb_message(exchange)
  rescue StandardError => e
    Rails.logger.info(e.message)
    Airbrake.notify(e)
    render json: { message: e.message }, status: :bad_request
  ensure
    conn&.close
  end

  private

  def display_kb_message(exchange)
    kb = KnowledgeBaseStatus.where(project_id: params[:project_id]).first_or_initialize
    exchange.publish(kb.json_message, key: ENV['KB_EXCHANGE_KEY'])
    render json: { message: I18n.t(:kb_message, project_id: kb.project_id) }, status: :ok
  end
end
