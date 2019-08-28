# frozen_string_literal: true

class FactoidAgeEstablished < FactoidAge
  def to_s
    I18n.t('factoids.age_established')
  end

  def inline
    I18n.t('factoids.age_established_inline')
  end

  def category
    :info
  end

  class << self
    def severity
      0
    end
  end
end
