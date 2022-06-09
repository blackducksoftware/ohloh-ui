# frozen_string_literal: true

module StatsdHelper
  def statsd_increment(msg)
    StatsD.increment(msg) if Rails.env.development?
  end

  def statsd_set(msg, params)
    StatsD.set(msg, params) if Rails.env.development?
  end
end
