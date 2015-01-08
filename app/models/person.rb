class Person < ActiveRecord::Base
  self.primary_key = :id
  self.per_page = 10

  belongs_to :account
  belongs_to :name
  belongs_to :project

  # TODO: change the below validation while migrating this model
  before_validation do |person|
    person.id = person.account_id
  end

  class << self
    def claimed(page)
      where { account_id.not_eq(nil) }.includes { account }.references(:all).paginate(page: page)
    end
  end
end
