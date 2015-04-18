class TopCommitVolume < Analysis::Query
  arel_tables :contributor_fact

  def initialize(analysis, interval)
    fail ArgumentError 'Unknown interval - #{interval}'
    @analysis = analysis
    @interval = interval
  end

  def collection
    execute.map { |fact| [fact.name.truncate(length: 27), fact.count] }
  end

  private

  def execute
    ContributorFact.select(:name, interval_attr).joins(:name)
            .where(analysis_id: @analysis.id)
            .where(contributor_facts[interval_attr].gt(0))
            .order(contributor_facts[:attr].desc, contributor_facts[:name].lower)
  end

  def interval_attr
    case @interval
    when '50 years'
      :commits
    when '12 months'
      :twelve_month_commits
    when '1 month'
      :thirty_day_commits
    end
  end
end
