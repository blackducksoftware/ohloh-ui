class Diff < ActiveRecord::Base
  belongs_to :commit
  belongs_to :fyle
  has_many :sloc_metrics, dependent: :destroy

  filterable_by ['fyles.name']
end
