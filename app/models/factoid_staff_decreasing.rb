# frozen_string_literal: true

class FactoidStaffDecreasing < FactoidStaff
  def inline
    I18n.t('factoids.staff_decreasing_inline')
  end

  def category
    :bad
  end

  class << self
    def severity
      -2
    end
  end
end
