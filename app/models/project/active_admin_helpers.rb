module Project::ActiveAdminHelpers
  extend ActiveSupport::Concern

  included do
    scope :last_analyzed_gteq_datetime, -> (date) {
      joins(:best_analysis).where("analyses.created_at >= ?", date)
    }

    scope :last_analyzed_lteq_datetime, -> (date) {
      joins(:best_analysis).where("analyses.created_at <= ?", (Time.parse(date) + 1.day).to_date.to_s)
    }

    def self.ransackable_scopes(_auth_object = nil)
      %i(last_analyzed_gteq_datetime last_analyzed_lteq_datetime)
    end
  end
end
