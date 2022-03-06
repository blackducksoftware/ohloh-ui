# frozen_string_literal: true

class CommitFlag < FisBase
  serialize :data

  belongs_to :commit, optional: true
  belongs_to :sloc_set, optional: true

  scope :new_languages, -> { where(type: 'CommitFlag::NewLanguage') }
end
