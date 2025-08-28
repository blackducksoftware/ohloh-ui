# frozen_string_literal: true

class ScanAnalytic < ApplicationRecord
  belongs_to :analysis
  belongs_to :code_set

  scope :analytics, -> { where(data_type: 'Analytics') }
  scope :charts, -> { where(data_type: 'Charts') }
end
