class SlaveLog < ActiveRecord::Base
  WARNING = 2

  belongs_to :job
end
