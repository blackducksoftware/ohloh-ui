class SlaveLog < ActiveRecord::Base
  DEBUG   = 0
  INFO    = 1
  WARNING = 2
  ERROR   = 3
  FATAL   = 4

  belongs_to :slave
  belongs_to :job
  belongs_to :code_set

  class << self
    def log(message = nil, level = DEBUG)
      create(message: message, level: level)
    end
  end
end
