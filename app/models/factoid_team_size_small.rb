# frozen_string_literal: true

class FactoidTeamSizeSmall < FactoidTeamSize
  def to_s
    I18n.t('factoids.team_size_small')
  end

  def inline
    I18n.t('factoids.team_size_small_inline')
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
