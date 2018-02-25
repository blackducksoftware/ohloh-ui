class SlocSet < FisBase
  belongs_to :code_set
  has_many :commit_flags, -> { order(time: :desc) }
  has_many :analysis_sloc_sets
end
