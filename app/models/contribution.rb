class Contribution < ActiveRecord::Base
  self.primary_key = :id

  belongs_to :position
  belongs_to :project
  belongs_to :person
  belongs_to :name_fact
  has_many :invites
end
