# frozen_string_literal: true

class FactoidTeamSizeOne < FactoidTeamSize
  def to_s
    I18n.t('factoids.team_size_one')
  end

  def inline
    I18n.t('factoids.team_size_one_inline')
  end

  def category
    :warning
  end

  class << self
    def severity
      -2
    end
  end
end
