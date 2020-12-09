# frozen_string_literal: true

namespace :kb_updater do
  desc 'Run the KB Updater to send updated data to the KB'

  task send_updates: :environment do
    conn = kb_rmq_connection
    exchange = get_exchange(conn)
    count = 0
    KnowledgeBaseStatus.items_to_sync.each do |knowledge_base_status|
      puts "KBUpdater Cron Job: converting and sending #{knowledge_base_status.project_id}"
      exchange.publish(knowledge_base_status.json_message, key: ENV['KB_EXCHANGE_KEY'])
      knowledge_base_status.update_attributes(in_sync: true, updated_at: Time.now.utc)
      count += 1
    end
    puts "#{count} projects updated"
    conn.close
  rescue StandardError => e
    Rails.logger.info(e.message)
    Airbrake.notify(e)
    conn.close
    raise StandardError, e.message # trigger healthchecks.io ping.
  end

  def kb_rmq_connection
    connection = Bunny.new(ENV['KB_AMQP_SERVER'], log_level: Logger::DEBUG, log_file: '/tmp/bunny.log',
                                                  heartbeat: 0, connection_timeout: ENV['KB_CONNECTION_TIMEOUT'].to_i,
                                                  threaded: false, automatically_recover: false)
    connection.start
  end

  def get_exchange(connection)
    channel = connection.create_channel
    channel.topic(ENV['KB_EXCHANGE_NAME'], type: :topic, durable: true, auto_delete: false)
  end
end
