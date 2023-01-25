# frozen_string_literal: true

module Project::ActiveAdminHelpers
  extend ActiveSupport::Concern

  included do
    scope :last_analyzed_gteq_datetime, lambda { |date_string|
      joins(:best_analysis).where('analyses.created_at >= ?', date_string)
    }

    scope :last_analyzed_lteq_datetime, lambda { |date_string|
      next_day_date_string = Time.zone.parse(date_string).advance(days: 1).to_date.to_s
      joins(:best_analysis).where('analyses.created_at <= ?', next_day_date_string)
    }

    scope :has_active_enlistments, -> { active_enlistments }

    scope :is_important, -> { with_important_code_locations }

    def self.ransackable_scopes(_auth_object = nil)
      %i[last_analyzed_gteq_datetime last_analyzed_lteq_datetime has_active_enlistments is_important]
    end
  end
end
