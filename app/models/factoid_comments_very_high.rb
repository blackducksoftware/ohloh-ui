# frozen_string_literal: true

class FactoidCommentsVeryHigh < FactoidComments
  def to_s
    I18n.t('factoids.comments_very_high')
  end

  def inline
    I18n.t('factoids.comments_very_high_inline')
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
