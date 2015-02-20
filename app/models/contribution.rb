class Contribution < ActiveRecord::Base
  self.primary_key = :id

  belongs_to :position
  belongs_to :project
  belongs_to :person
  belongs_to :contributor_fact, foreign_key: 'name_fact_id'
  has_many :invites
end
