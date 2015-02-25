class Contribution < ActiveRecord::Base
  self.primary_key = :id

  belongs_to :position
  belongs_to :project
  belongs_to :person
  belongs_to :name_fact
  has_many :invites

  class << self
    def generate_id_from_project_id_and_name_id(project_id, name_id)
      ((project_id << 32) + name_id + 0x80000000)
    end
  end
end
