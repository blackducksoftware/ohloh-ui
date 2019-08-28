# frozen_string_literal: true

class FactoidTeamSizeAverage < FactoidTeamSize
  def to_s
    I18n.t('factoids.team_size_average')
  end

  def inline
    I18n.t('factoids.team_size_average_inline')
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
