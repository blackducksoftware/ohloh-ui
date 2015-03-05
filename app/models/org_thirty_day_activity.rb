class OrgThirtyDayActivity < ActiveRecord::Base
  SORT_TYPES = [['All Organizations', 'all_orgs'], %w(Commercial commercial), %w(Education educational),
                %w(Government government), %w(Non-Profit non_profit), %w(Large large),
                %w(Medium medium), %w(Small small)]

  belongs_to :organization

  scope :filter_all_orgs, -> { with_thirty_day_commit_count }
  scope :filter_small_orgs, -> { with_thirty_day_commit_count.where(project_count: 1..10) }
  scope :filter_medium_orgs, -> { with_thirty_day_commit_count.where(project_count: 11..50) }
  scope :filter_large_orgs, -> { with_thirty_day_commit_count.where(arel_table[:project_count].gt(50)) }
  scope :filter_commercial_orgs, -> { with_thirty_day_commit_count.where(org_type: 1) }
  scope :filter_educational_orgs, -> { with_thirty_day_commit_count.where(org_type: 2) }
  scope :filter_government_orgs, -> { with_thirty_day_commit_count.where(org_type: 3) }
  scope :filter_non_profit_orgs, -> { with_thirty_day_commit_count.where(org_type: 4) }

  class << self
    def most_active_orgs
      commits_per_affliate = (arel_table[:thirty_day_commit_count] / arel_table[:affiliate_count])
      with_commits_and_affiliates
        .select([Arel.star, commits_per_affliate.as('commits_per_affiliate')])
        .order(commits_per_affliate.desc).limit(3)
    end

    private

    def method_missing(m, *args, &block)
      if m =~ /filter_/
        filter_all_orgs
      else
        super
      end
    end

    def with_commits_and_affiliates
      orgs = Organization.arel_table
      joins(:organization)
        .where(id: orgs[:thirty_day_activity_id])
        .where(arel_table[:thirty_day_commit_count].gt(0)
        .and(arel_table[:affiliate_count].gt(0)))
    end

    def with_thirty_day_commit_count
      orgs = Organization.arel_table
      joins(:organization)
        .where(id: orgs[:thirty_day_activity_id])
        .where.not(thirty_day_commit_count: nil)
        .order(thirty_day_commit_count: :desc)
        .limit(5)
    end
  end
end
