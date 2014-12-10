class Permission < ActiveRecord::Base
  belongs_to :target, polymorphic: true
end
