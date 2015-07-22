class SlaveLog < ActiveRecord::Base
  belongs_to :slave
  belongs_to :job
  belongs_to :code_set

  # sortable_by :created_on_desc, { :created_on_desc => 'slave_logs.created_on desc' }
  # filterable_by '(lower(slave_logs.message) LIKE #{term} OR lower(slaves.hostname) LIKE #{term})'

  unless defined?(SlaveLog::DEBUG)
    DEBUG   = 0
    INFO    = 1
    WARNING = 2
    ERROR   = 3
    FATAL   = 4
  end

  # Creates a new log entry with the specified message.
  # The hostname and timestamp are applied automatically.
  def self.log(message=nil, level=SlaveLog::DEBUG)
    SlaveLog.create(:message => message, :level => level)
  end
end
