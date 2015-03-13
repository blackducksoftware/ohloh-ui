class NamedCommit < ActiveRecord::Base
  self.primary_key = :id

  belongs_to :commit
  belongs_to :analysis
  belongs_to :project
  belongs_to :position
  belongs_to :account
  belongs_to :person
  belongs_to :contribution

  has_many :commit_flags, class_name: CommitFlag, foreign_key: :commit_id
end
