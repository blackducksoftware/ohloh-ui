# frozen_string_literal: true

class FactoidStaffStable < FactoidStaff
  def inline
    I18n.t('factoids.staff_stable_inline')
  end

  def category
    :info
  end

  class << self
    def severity
      -2
    end
  end
end
