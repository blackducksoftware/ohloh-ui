module AccountScopes
  ANONYMOUS_ACCOUNTS = %w(anonymous_coward ohloh_slave uber_data_crawler).freeze
  ANONYMOUS_ACCOUNTS_EMAILS = %w(anon@openhub.net info@openhub.net uber_data_crawler@openhub.net).freeze

  extend ActiveSupport::Concern

  included do
    scope :simple_search, lambda { |query|
      where(['lower(name) like :term OR lower(login) like :term', term: "%#{query.downcase}%"])
        .order("COALESCE( NULLIF( POSITION('#{query}' in lower(login)), 0), 100), CHAR_LENGTH(login)")
        .limit(10)
    }

    scope :recently_active, lambda {
      where(level: Account::Access::DEFAULT)
        .joins(vitas: :vita_fact)
        .where(VitaFact.arel_table[:last_checkin].gt(1.month.ago))
        .where(arel_table[:best_vita_id].eq(Vita.arel_table[:id]))
        .where.not(best_vita_id: nil)
        .order('COALESCE(name_facts.thirty_day_commits, 0) DESC').limit(10)
    }

    scope :with_facts, lambda {
      joins(positions: :project)
        .joins('INNER JOIN name_facts ON name_facts.name_id = positions.name_id')
        .where.not(Position.arel_table[:name_id].eq(nil))
        .where(ContributorFact.arel_table[:analysis_id].eq(Project.arel_table[:best_analysis_id]))
    }

    scope :in_good_standing, -> { where('level >= 0') }
    scope :from_param, -> (param) { in_good_standing.where(arel_table[:login].eq(param).or(arel_table[:id].eq(param))) }
    scope :active, -> { where(level: 0) }
    scope :non_anonymous, -> { where.not(login: ANONYMOUS_ACCOUNTS, email: ANONYMOUS_ACCOUNTS_EMAILS) }
    scope :unverified, lambda { |limit = nil|
      select('accounts.id, accounts.email')
        .where(level: 0)
        .joins('LEFT OUTER JOIN verifications v ON v.account_id = accounts.id')
        .where('v.account_id IS NULL')
        .limit(limit)
    }
    scope :reverification_not_initiated, lambda { |limit = nil|
      unverified
        .joins('LEFT OUTER JOIN reverification_trackers r ON r.account_id = accounts.id')
        .where('r.account_id IS NULL').joins('LEFT OUTER JOIN positions p ON p.account_id = accounts.id')
        .where('p.account_id IS NULL')
        .limit(limit)
    }
  end
end
