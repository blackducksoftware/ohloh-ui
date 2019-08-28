# frozen_string_literal: true

class FactoidActivityIncreasing < FactoidActivity
  def to_s
    I18n.t('factoids.activity_increasing')
  end

  def inline
    I18n.t('factoids.activity_increasing_inline')
  end

  def category
    :good
  end

  class << self
    def severity
      2
    end
  end
end
