# frozen_string_literal: true

class FactoidAgeOld < FactoidAge
  def to_s
    I18n.t('factoids.age_old')
  end

  def inline
    I18n.t('factoids.age_old_inline')
  end

  def category
    :good
  end

  class << self
    def severity
      1
    end
  end
end
