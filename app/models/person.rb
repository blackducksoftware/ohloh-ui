class Person < ActiveRecord::Base
  self.primary_key = :id

  belongs_to :name
  belongs_to :project
  # TODO: change the below validation while migrating this model
  before_validation do |person|
    person.id = person.account_id
  end
end
