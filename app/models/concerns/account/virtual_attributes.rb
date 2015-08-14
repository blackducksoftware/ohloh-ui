module Account::VirtualAttributes
  extend ActiveSupport::Concern

  included do
    attr_reader :about_raw
    attr_accessor :digits_credentials, :digits_service_provider_url, :digits_oauth_timestamp
  end

  def about_raw=(value)
    @about_raw = value
    about_markup_id.nil? ? build_markup(raw: value) : markup.raw = value
  end
end
