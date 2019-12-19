# frozen_string_literal: true

class FactoidAgeVeryOld < FactoidAge
  def to_s
    I18n.t('factoids.age_very_old')
  end

  def inline
    I18n.t('factoids.age_very_old_inline')
  end

  def category
    :good
  end

  class << self
    def severity
      3
    end
  end
end
