# frozen_string_literal: true

class Permission < ActiveRecord::Base
  belongs_to :target, polymorphic: true

  acts_as_editable editable_attributes: [:remainder],
                   merge_within: 30.minutes
  acts_as_protected parent: :target, always_protected: true
end
