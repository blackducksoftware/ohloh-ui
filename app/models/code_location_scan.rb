# frozen_string_literal: true

class CodeLocationScan < ApplicationRecord
  self.table_name = 'oh.code_location_scan'

  belongs_to :code_location
end
