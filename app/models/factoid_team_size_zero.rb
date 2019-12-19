# frozen_string_literal: true

class FactoidTeamSizeZero < FactoidTeamSize
  def to_s
    I18n.t('factoids.team_size_zero')
  end

  def inline
    I18n.t('factoids.team_size_zero_inline')
  end

  def category
    :bad
  end

  class << self
    def severity
      -3
    end
  end
end
