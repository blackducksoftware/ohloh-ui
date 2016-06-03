class Analysis::AgeHistogram
  class << self
    def execute
      Analysis.select("count(*) as value, date_trunc('day', logged_at) as logged_date")
              .joins(:project)
              .where(project_conditions)
              .where.not(logged_at: nil)
              .where(in_last_two_months)
              .group('logged_date')
              .order('logged_date')
    end

    private

    def project_conditions
      projects[:best_analysis_id].eq(analyses[:id])
    end

    def projects
      Project.arel_table
    end

    def analyses
      Analysis.arel_table
    end

    def in_last_two_months
      analyses[:logged_at].gt(Time.current - 63.days)
    end
  end
end
