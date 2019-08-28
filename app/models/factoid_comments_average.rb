# frozen_string_literal: true

class FactoidCommentsAverage < FactoidComments
  def to_s
    I18n.t('factoids.comments_average')
  end

  def inline
    I18n.t('factoids.comments_average_inline')
  end

  def category
    :info
  end

  class << self
    def severity
      -1
    end
  end
end
