# frozen_string_literal: true

class FactoidStaffIncreasing < FactoidStaff
  def inline
    I18n.t('factoids.staff_increasing_inline')
  end

  def category
    :good
  end

  class << self
    def severity
      -2
    end
  end
end
