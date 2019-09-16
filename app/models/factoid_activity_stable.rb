# frozen_string_literal: true

class FactoidActivityStable < FactoidActivity
  def to_s
    I18n.t('factoids.activity_stable')
  end

  def inline
    I18n.t('factoids.activity_stable_inline')
  end

  def category
    :info
  end

  class << self
    def severity
      -2
    end
  end
end
