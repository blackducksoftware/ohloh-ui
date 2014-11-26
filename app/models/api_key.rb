class ApiKey < ActiveRecord::Base
  DEFAULT_DAILY_LIMIT = 1000
  STATUS_OK = 0
  STATUS_LIMIT_EXCEEDED = 1
  STATUS_DISABLED = 2

  after_initialize :defaults

  validates :description, length: { within: 4..2000 }
  validates :name, length: { within: 4..50 }
  validates :terms, acceptance: { accept: true, message: I18n.t(:must_accept_terms) }
  validates :key, uniqueness: true

  def defaults
    daily_limit ||= DEFAULT_DAILY_LIMIT
    key ||= @oauth_client.key
    secret ||= @oauth_client.secret
  end
end
