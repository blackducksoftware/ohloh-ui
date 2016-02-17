module ContributionAssociations
  extend ActiveSupport::Concern

  included do
    belongs_to :position
    belongs_to :project
    belongs_to :person
    belongs_to :name_fact
    belongs_to :contributor_fact, foreign_key: 'name_fact_id'
    has_many :invites
    has_many :kudos, ->(contrib) { joins(:name_fact).where(NameFact.arel_table[:id].eq(contrib.name_fact_id)) },
             primary_key: :project_id, foreign_key: :project_id
  end

  def readonly?
    true
  end
end
