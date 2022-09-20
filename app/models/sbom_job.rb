# frozen_string_literal: true

class SbomJob < Job
  self.abstract_class = true
  self.table_name = 'fis.jobs'
end
