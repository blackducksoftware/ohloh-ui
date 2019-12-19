# frozen_string_literal: true

class FactoidActivityDecreasing < FactoidActivity
  def to_s
    I18n.t('factoids.activity_decreasing')
  end

  def inline
    I18n.t('factoids.activity_decreasing_inline')
  end

  def category
    :bad
  end

  class << self
    def severity
      -2
    end
  end
end
