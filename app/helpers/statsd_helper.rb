# frozen_string_literal: true

module StatsdHelper
  def statsd_increment(msg)
    StatsD.increment(msg)  unless ENV['KUBERNETES_PORT']
  end

  def statsd_set(msg, params)
    StatsD.set('Openhub.Api.Key.limit_exceeded', params[:api_key]) unless ENV['KUBERNETES_PORT']
  end
end