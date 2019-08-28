# frozen_string_literal: true

class FactoidCommentsVeryLow < FactoidComments
  def to_s
    I18n.t('factoids.comments_very_low')
  end

  def inline
    I18n.t('factoids.comments_very_low_inline')
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
