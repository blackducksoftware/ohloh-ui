# frozen_string_literal: true

class Permission < ApplicationRecord
  include ActsAsEditable
  include ActsAsProtected
  belongs_to :target, polymorphic: true, optional: true

  acts_as_editable editable_attributes: [:remainder],
                   merge_within: 30.minutes
  acts_as_protected parent: :target, always_protected: true
end
