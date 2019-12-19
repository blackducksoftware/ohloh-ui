# frozen_string_literal: true

class FactoidCommentsLow < FactoidComments
  def to_s
    I18n.t('factoids.comments_low')
  end

  def inline
    I18n.t('factoids.comments_low_inline')
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
