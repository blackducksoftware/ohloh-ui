# frozen_string_literal: true

namespace :kb_updater do
  desc 'Run the KB Updater to send updated data to the KB'

  task send_updates: :environment do
    conn = KnowledgeBaseQueue.connect
    exchange = KnowledgeBaseQueue.get_exchange(conn)
    count = 0
    KnowledgeBaseStatus.items_to_sync.limit(1000).each do |knowledge_base_status|
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
end
