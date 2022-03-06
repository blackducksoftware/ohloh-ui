# frozen_string_literal: true

class Analysis::TopCommitVolume < Analysis::QueryBase
  INTERVAL_ATTRS = { '50 years' => :commits, '12 months' => :twelve_month_commits,
                     '1 month' => :thirty_day_commits }.freeze

  arel_tables :contributor_fact, :name

  # rubocop:disable Lint/MissingSuper # parent has differing args.
  def initialize(analysis, interval)
    @analysis = analysis
    @interval = interval
    raise ArgumentError, "Unknown interval - #{interval}" unless interval_attr
  end
  # rubocop:enable Lint/MissingSuper

  def collection
    execute.map { |fact| [fact.committer_name[0..27], fact.count] }
  end

  private

  def execute
    ContributorFact.select(select_clause).joins(:name)
                   .where(analysis_id: @analysis.id).where(conditions)
                   .order(contributor_facts[interval_attr].desc, names[:name].lower)
  end

  def select_clause
    [names[:name].as('committer_name'), contributor_facts[interval_attr].as('count')]
  end

  def conditions
    contributor_facts[interval_attr].gt(0)
  end

  def interval_attr
    @interval_attr ||= INTERVAL_ATTRS[@interval]
  end
end
