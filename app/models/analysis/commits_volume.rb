class CommitsVolume < Analysis::Query
  arel_tables :name, :analysis_sloc_set, :commit, :analysis_alias

  def initialize(analysis, interval)
    @analysis = analysis
    @interval = interval
  end

  def collection
    execute.map { |row| [row.name, row.count] }
  end

  private

  def execute
    Analysis.select([names[:name], Arel.star.count('count')])
            .joins(analysis_sloc_sets: { sloc_set: { code_set: :commits }}, analysis_aliases: :preferred_name)
            .where(commits[:position].lteq(analysis_sloc_sets[:as_of]))
            .where(commits[:name_id].eq(analysis_aliases[:commit_name_id]))
            .where(id: @analysis.id)
            .where(commits[:time].eq(date_interval))
            .group(names[:name])
            .order('count DESC LOWER(names.name)')
  end

  def date_interval
    "analyses.max_month + INTERVAL '1 month' - INTERVAL '#{@interval}'"
  end
end
