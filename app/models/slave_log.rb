class SlaveLog < SecondBase::Base
  INFO = 1
  WARNING = 2

  belongs_to :job
  belongs_to :slave
end
