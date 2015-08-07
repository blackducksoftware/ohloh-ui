require 'test_helper'

class CompleteJobTest < ActiveSupport::TestCase
  describe 'try_create' do
    it 'must be nil when job exists matching the given code_set_id' do
      code_set = create(:code_set)
      create(:fetch_job, code_set: code_set)

      CompleteJob.try_create(code_set, 0).must_be_nil
    end

    it 'must create a complete_job when no matching job exists' do
      code_set = create(:code_set)
      create(:fetch_job)

      job = CompleteJob.try_create(code_set, 0)
      job.must_be_instance_of(CompleteJob)
    end
  end
end
