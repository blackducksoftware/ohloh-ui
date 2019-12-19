# frozen_string_literal: true

class Analysis::MonthlyLanguage
  class << self
    def last_run
      last_run = Setting.get_value('monthly_language_analysis')
      return I18n.t('.no_data') if last_run.nil?

      last_run.to_date.to_s(:mdy)
    end
  end
end
