# frozen_string_literal: true

class Api::V1::KnowledgeBaseStatusController < ApplicationController
  include JwtHelper

  skip_before_action :verify_authenticity_token
  before_action :authenticate_jwt

  def sync
    conn = KnowledgeBaseQueue.connect
    exchange = KnowledgeBaseQueue.get_exchange(conn)
    display_kb_message(exchange)
  rescue StandardError => e
    AppLogger.info(e.message)
    Airbrake.notify(e)
    json_response_with_deprecation({ message: e.message }, status: :bad_request)
  ensure
    conn&.close
  end

  private

  def display_kb_message(exchange)
    kb = KnowledgeBaseStatus.find_by(project_id: params[:project_id])
    exchange.publish(kb.json_message, key: ENV.fetch('KB_EXCHANGE_KEY', nil))
    kb.update(in_sync: true, updated_at: Time.now.utc)
    json_response_with_deprecation({ message: I18n.t(:kb_message, project_id: kb.project_id) }, status: :ok)
  end
end
