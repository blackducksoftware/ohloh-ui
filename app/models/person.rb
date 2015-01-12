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
    def claimed(page=1)
      where.not(account_id: nil).includes(:account).references(:all)
      .order('kudo_rank desc nulls last').paginate(page: page)
    end
  end
end
