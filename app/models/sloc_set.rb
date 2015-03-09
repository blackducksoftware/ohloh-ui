class SlocSet < ActiveRecord::Base
  belongs_to :code_set
  has_many :commit_flags, -> { order(time: :desc) }
end
