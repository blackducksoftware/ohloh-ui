class Analysis::AgeHistogram
  class << self
    def execute
      select_manager = analyses.project(count_star, date_trunc)
                               .join(projects)
                               .on(project_conditions)
                               .where(logged_at_not_null)
                               .where(in_last_two_months)
                               .group('logged_date')
                               .order('logged_date')
       histogram_data = Struct.new(:value, :logged_date)
       Analysis.connection.execute(select_manager.to_sql).values.collect do |v|
         histogram_data.new(v[0].to_i, Time.parse(v[1] + " UTC"))
       end
    end

    private

    def projects
      Project.arel_table
    end

    def analyses
      Analysis.arel_table
    end

    def count_star
      Arel::Nodes::NamedFunction.new('COUNT', [analyses[Arel.star]], 'value')
    end

    def date_trunc
      Arel::Nodes::NamedFunction.new('DATE_TRUNC', [Arel.sql("'day'"), analyses[:logged_at]], 'logged_date')
    end

    def project_conditions
      projects[:best_analysis_id].eq(analyses[:id])
    end

    def logged_at_not_null
      analyses[:logged_at].not_eq(nil)
    end

    def in_last_two_months
      analyses[:logged_at].gt(Time.current - 63.days)
    end
  end
end
