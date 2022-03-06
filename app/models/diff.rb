# frozen_string_literal: true

class Diff < FisBase
  self.primary_key = 'id'
  belongs_to :commit, optional: true
  belongs_to :fyle, optional: true
  has_many :sloc_metrics, dependent: :destroy

  filterable_by ['fyles.name']
end
