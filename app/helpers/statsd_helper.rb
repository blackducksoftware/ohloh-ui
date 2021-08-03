# frozen_string_literal: true

module StatsdHelper
  def statsd_increment(msg)
    StatsD.increment(msg) unless ENV['KUBERNETES_PORT']
  end

  def statsd_set(msg, params)
    StatsD.set(msg, params) unless ENV['KUBERNETES_PORT']
  end
end
