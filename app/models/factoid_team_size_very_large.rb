# frozen_string_literal: true

class FactoidTeamSizeVeryLarge < FactoidTeamSize
  def to_s
    I18n.t('factoids.team_size_very_large')
  end

  def inline
    I18n.t('factoids.team_size_very_large_inline')
  end

  def category
    :good
  end

  class << self
    def severity
      3
    end
  end
end
