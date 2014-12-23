class Person < ActiveRecord::Base
  self.primary_key = :id

  belongs_to :name
  belongs_to :project
  belongs_to :account
end
