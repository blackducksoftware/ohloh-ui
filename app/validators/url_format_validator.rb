# frozen_string_literal: true

class UrlFormatValidator < ActiveModel::EachValidator
  # With Ruby 2.2, the default URI parser is more forgiving than we want, so use the same trick Rails does in Rack
  # see: https://bugs.ruby-lang.org/issues/10669
  def validate_each(record, attribute, value)
    valid_url = begin
                  @parser ||= defined?(URI::RFC2396_Parser) ? URI::RFC2396_Parser.new : URI
                  @parser.parse(value).is_a?(URI::HTTP)
                rescue URI::InvalidURIError
                  false
                end

    record.errors.add(attribute, options[:message] || I18n.t('accounts.invalid_url_format')) unless valid_url
  end
end
