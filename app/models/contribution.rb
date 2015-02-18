class Contribution < ActiveRecord::Base
  self.primary_key = :id

  belongs_to :position
  belongs_to :project
  belongs_to :person
  has_many :invites
end
