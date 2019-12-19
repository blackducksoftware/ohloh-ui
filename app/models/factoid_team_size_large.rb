# frozen_string_literal: true

class FactoidTeamSizeLarge < FactoidTeamSize
  def to_s
    I18n.t('factoids.team_size_large')
  end

  def inline
    I18n.t('factoids.team_size_large_inline')
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
