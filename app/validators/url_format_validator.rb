class UrlFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    valid_url = begin
      URI.parse(value).is_a?(URI::HTTP)
    rescue URI::InvalidURIError
      false
    end

    record.errors.add(attribute, options[:message] || I18n.t('accounts.invalid_url_format')) unless valid_url
  end
end
