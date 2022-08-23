module Project::ActiveAdminHelpers
  extend ActiveSupport::Concern

  included do
    scope :last_analyzed_gteq_datetime, -> (date) {
      joins(:best_analysis).where("analyses.created_at >= ?", date)
    }

    scope :last_analyzed_lteq_datetime, -> (date) {
      joins(:best_analysis).where("analyses.created_at <= ?", (Time.parse(date) + 1.day).to_date.to_s)
    }

    scope :has_active_enlistments, -> { active_enlistments }

    def self.ransackable_scopes(_auth_object = nil)
      %i(last_analyzed_gteq_datetime last_analyzed_lteq_datetime has_active_enlistments)
    end
  end
end
