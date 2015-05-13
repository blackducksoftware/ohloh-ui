module AccountScopes
  extend ActiveSupport::Concern

  included do
    scope :simple_search, lambda { |query|
      where(['lower(name) like :term OR lower(login) like :term', term: "%#{query.downcase}%"])
        .order("COALESCE( NULLIF( POSITION('#{query}' in lower(login)), 0), 100), CHAR_LENGTH(login)")
        .limit(10)
    }

    scope :recently_active, lambda {
      joins(vitas: :vita_fact)
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
    scope :from_param, ->(param) { in_good_standing.where(arel_table[:login].eq(param).or(arel_table[:id].eq(param))) }
    scope :active, -> { where(level: 0) }
  end
end
