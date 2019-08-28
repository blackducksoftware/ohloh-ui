# frozen_string_literal: true

class FactoidCommentsHigh < FactoidComments
  def to_s
    I18n.t('factoids.comments_high')
  end

  def inline
    I18n.t('factoids.comments_high_inline')
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
