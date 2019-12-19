# frozen_string_literal: true

class FactoidAgeYoung < FactoidAge
  def to_s
    I18n.t('factoids.age_young')
  end

  def inline
    I18n.t('factoids.age_young_inline')
  end

  def category
    :warning
  end

  class << self
    def severity
      -1
    end
  end
end
