# frozen_string_literal: true

class WorkerLog < ApplicationRecord
  INFO = 1
  WARNING = 2

  belongs_to :job, optional: true
  belongs_to :worker, optional: true
end
