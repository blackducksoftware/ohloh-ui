class SlocSet < ActiveRecord::Base
  belongs_to :code_set
  has_one :repository, foreign_key: :best_code_set_id, primary_key: :code_set_id
  has_many :commit_flags, -> { order(time: :desc) }
  has_many :analysis_sloc_sets
end
