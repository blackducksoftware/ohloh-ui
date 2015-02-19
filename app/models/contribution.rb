class Contribution < ActiveRecord::Base
  belongs_to :position
  belongs_to :project
  belongs_to :person
  belongs_to :contributor_fact, foreign_key: 'name_fact_id'
end
