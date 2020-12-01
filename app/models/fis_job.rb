# frozen_string_literal: true

class FisJob < Job
  self.abstract_class = true
  self.table_name = 'fis.jobs'

  belongs_to :slave
  has_many :slave_logs
end
