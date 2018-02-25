require 'test_helper'

class SlocJobTest < ActiveSupport::TestCase
  describe 'progress_message' do
    it 'should return required message' do
      job = SlocJob.create
      job.progress_message.must_equal 'Step 3 of 3: Counting lines of source code'
    end
  end
end
