# frozen_string_literal: true

module KnowledgeBaseQueue
  module_function

  def connect
    rmq_connection_url = "amqp://#{ENV['KB_AMQP_USER']}:#{ENV['KB_AMQP_PASSWORD']}@#{ENV['KB_AMQP_HOST']}"
    connection = Bunny.new(rmq_connection_url, log_level: Logger::DEBUG, log_file: '/tmp/bunny.log',
                                               heartbeat: 0, connection_timeout: ENV['KB_CONNECTION_TIMEOUT'].to_i,
                                               threaded: false, automatically_recover: false)
    connection.start
  end

  def get_exchange(connection)
    channel = connection.create_channel
    channel.topic(ENV['KB_EXCHANGE_NAME'], type: :topic, durable: true, auto_delete: false)
  end
end
