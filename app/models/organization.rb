class Organization < ActiveRecord::Base
  has_one :permission, as: :target
end
