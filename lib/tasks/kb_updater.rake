# frozen_string_literal: true

namespace :kb_updater do
  desc 'Run the KB Updater to send updated data to the KB'

  task send_updates: :environment do
    conn = kb_rmq_connection
    count = 0
    KnowledgeBaseStatus.items_to_sync.each do |knowledge_base_status|
      puts "KBUpdater Cron Job: converting and sending #{knowledge_base_status.project_id}"
      publish_to_kb(conn, knowledge_base_status.json_message)
      knowledge_base_status.update_attributes(in_sync: true, updated_at: Time.now.utc)
      count += 1
    end
    puts "#{count} projects updated"
    conn.close
  rescue StandardError => e
    puts e.message
    Rails.logger.info(e.message)
    Airbrake.notify(e)
  end

  def kb_rmq_connection
    connection = Bunny.new(ENV['KB_AMQP_SERVER'], log_level: Logger::DEBUG, log_file: '/tmp/bunny.log',
                                                  heartbeat: 0, connection_timeout: ENV['KB_CONNECTION_TIMEOUT'].to_i,
                                                  threaded: false, automatically_recover: false)
    connection.start
  end

  def publish_to_kb(connection, message)
    channel = connection.create_channel
    exchange = channel.topic(ENV['KB_EXCHANGE_NAME'], type: :topic, durable: true, auto_delete: false)
    exchange.publish(message, key: ENV['KB_EXCHANGE_KEY'])
  end
end
