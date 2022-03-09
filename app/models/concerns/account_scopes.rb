# frozen_string_literal: true

module AccountScopes
  ANONYMOUS_ACCOUNTS = %w[anonymous_coward ohloh_slave uber_data_crawler].freeze
  ANONYMOUS_ACCOUNTS_EMAILS = %w[anon@openhub.net info@openhub.net uber_data_crawler@openhub.net].freeze

  extend ActiveSupport::Concern

  included do
    scope :simple_search, lambda { |query|
      return none if query.match(Patterns::BAD_QUERY)

      where(['lower(name) like :term OR lower(login) like :term', { term: "%#{query.downcase}%" }])
        .order(Arel.sql("COALESCE( NULLIF( POSITION('#{query}' in lower(login)), 0), 100), CHAR_LENGTH(login)"))
        .limit(10)
    }

    scope :recently_active, lambda {
      where(level: Account::Access::DEFAULT)
        .joins(best_account_analysis: :account_analysis_fact)
        .where("last_checkin > '#{1.month.ago.to_date}'")
        .order('name_facts.thirty_day_commits DESC NULLS LAST').limit(10)
    }

    scope :with_facts, lambda {
      joins(positions: :project)
        .joins('INNER JOIN name_facts ON name_facts.name_id = positions.name_id')
        .where(projects: { deleted: false })
        .where.not(Position.arel_table[:name_id].eq(nil))
        .where(ContributorFact.arel_table[:analysis_id].eq(Project.arel_table[:best_analysis_id]))
    }

    scope :in_good_standing, -> { where('level >= 0') }
    scope :from_param, ->(param) { in_good_standing.where(arel_table[:login].eq(param).or(arel_table[:id].eq(param))) }
    scope :active, -> { where(level: 0) }
    scope :non_anonymous, -> { where.not(login: ANONYMOUS_ACCOUNTS, email: ANONYMOUS_ACCOUNTS_EMAILS) }

    scope :reverification_not_initiated, lambda { |limit = 0|
      find_by_sql ["SELECT DISTINCT(accounts.id) FROM accounts WHERE level = 0 AND id IN
                    (SELECT DISTINCT(account_id) FROM successful_accounts) AND id NOT IN
                    (SELECT DISTINCT(account_id) FROM reverification_trackers) AND id NOT IN
                    (SELECT DISTINCT(account_id) FROM verifications) AND id NOT IN
                    (SELECT DISTINCT(account_id) FROM positions) AND id NOT IN
                    (SELECT DISTINCT(account_id) FROM edits) AND id NOT IN
                    (SELECT DISTINCT(account_id) FROM posts) AND id NOT IN
                    (SELECT DISTINCT(account_id) FROM reviews) AND id NOT IN
                    (SELECT DISTINCT(sender_id) FROM kudos) AND id NOT IN
                    (SELECT DISTINCT(account_id) FROM stacks WHERE account_id IS NOT NULL) AND id NOT IN
                      (SELECT DISTINCT(account_id) from manages INNER JOIN projects ON manages.target_id = projects.id
                        WHERE projects.deleted = 'f' AND (manages.approved_by IS NOT NULL)
                      AND manages.deleted_by IS NULL AND manages.deleted_at IS NULL
                      AND manages.target_type = 'Project') LIMIT :limit", { limit: limit }]
    }
  end
end
