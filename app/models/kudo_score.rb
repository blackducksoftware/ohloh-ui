class KudoScore < ActiveRecord::Base
  class << self
    def find_by_account_or_name_and_project(person)
      find_by(account_id: person.account_id) ||
        find_by(project_id: person.project_id, name_id: person.name_id)
    end
  end
end
