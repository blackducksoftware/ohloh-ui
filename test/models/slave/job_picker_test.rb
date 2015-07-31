require 'test_helper'

class Slave::JobPickerTest < ActiveSupport::TestCase
  it 'must find the correct job' do
    repository = create(:repository)
    Slave.create!(hostname: Socket.gethostname, allow_deny: 'allow')
    Slave::JobPicker.new.send(:scheduled_job).must_equal repository.jobs.first
  end
end

