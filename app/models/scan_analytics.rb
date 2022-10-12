# frozen_string_literal: true

class ScanAnalytic < ApplicationRecord
  belongs_to :analysis
  belongs_to :code_set
end
