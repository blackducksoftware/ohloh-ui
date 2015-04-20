class TopCommitVolume < Analysis::Query
  INTERVAL_ATTRS = { '50 years' => :commits , '12 months' => :twelve_month_commits, '1 month' => :thirty_day_commits }

  arel_tables :contributor_fact, :name

  def initialize(analysis, interval)
    @analysis = analysis
    @interval = interval
    fail ArgumentError 'Unknown interval - #{interval}' unless interval_attr
  end

  def collection
    execute.map { |fact| [fact.committer_name[0..27], fact.count] }
  end

  private

  def execute
    ContributorFact.select([names[:name].as('committer_name'), contributor_facts[interval_attr].as('count')])
            .joins(:name).where(analysis_id: @analysis.id).where(contributor_facts[interval_attr].gt(0))
            .order(contributor_facts[interval_attr].desc, names[:name].lower)
  end

  def interval_attr
    @interval_attr ||= INTERVAL_ATTRS[@interval]
  end
end
