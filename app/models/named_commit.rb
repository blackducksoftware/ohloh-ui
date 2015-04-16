class NamedCommit < ActiveRecord::Base
  self.primary_key = :id

  belongs_to :commit
  belongs_to :analysis
  belongs_to :code_set
  belongs_to :project
  belongs_to :position
  belongs_to :account
  belongs_to :person
  belongs_to :contribution

  has_many :commit_flags, class_name: CommitFlag, foreign_key: :commit_id

  scope :by_newest, -> { order('commits.time desc') }
  scope :by_oldest, -> { order('commits.time asc') }

  filterable_by ['effective_name', 'commits.comment', 'accounts.akas']
end
