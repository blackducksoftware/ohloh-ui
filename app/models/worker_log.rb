# frozen_string_literal: true

class WorkerLog < ActiveRecord::Base
  INFO = 1
  WARNING = 2

  belongs_to :job
  belongs_to :worker
end
