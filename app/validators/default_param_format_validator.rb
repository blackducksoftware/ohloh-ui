class DefaultParamFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank? || value.match(Patterns::DEFAULT_PARAM_FORMAT)

    record.errors.add(attribute, I18n.t('invalid_default_param'))
  end
end
