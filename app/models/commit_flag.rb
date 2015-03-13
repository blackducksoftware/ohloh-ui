class CommitFlag < ActiveRecord::Base
  serialize :data

  belongs_to :commit
  belongs_to :sloc_set

  scope :new_languages, -> { where(type: 'CommitFlag::NewLanguage') }
end
