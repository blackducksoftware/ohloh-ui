require 'test_helper'

class SlaveLogTest < ActiveSupport::TestCase
  describe 'log' do
    it 'must create a new record with default level' do
      message = Faker::Lorem.sentence

      SlaveLog.log(message)

      slave_log = SlaveLog.last
      slave_log.message.must_equal message
      slave_log.level.must_equal SlaveLog::DEBUG
    end
  end
end
