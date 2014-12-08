class Organization < ActiveRecord::Base
  has_one :permission, as: :target
  belongs_to :logo
end
