module AccountScopes
  extend ActiveSupport::Concern

  included do
    sifter :name_or_login_like do |query|
      name.like("%#{query}%") | login.like("%#{query}%")
    end

    scope :simple_search, lambda { |query|
      where { sift :name_or_login_like, query }
        .order("COALESCE( NULLIF( POSITION('#{query}' in lower(login)), 0), 100), CHAR_LENGTH(login)")
        .limit(10)
    }

    scope :recently_active, lambda {
      joins { [vitas.vita_fact, best_vita] }
        .where { (name_facts.last_checkin > 1.month.ago) & (best_vita_id.not_eq(nil)) }
        .order { coalesce(name_facts.thirty_day_commits, 0).desc }.limit(10)
    }

    scope :with_facts, lambda {
      joins { positions.project }
        .joins { ['INNER JOIN name_facts ON name_facts.name_id = positions.name_id'] }
        .where { positions.name_id.not_eq(nil) }
        .where { name_facts.analysis_id.eq(projects.best_analysis_id) & name_facts.type.eq('ContributorFact') }
    }

    scope :in_good_standing, -> { where('level >= 0') }

    scope :from_param, ->(param) { where(arel_table[:login].eq(param).or(arel_table[:id].eq(param))) }
  end
end
