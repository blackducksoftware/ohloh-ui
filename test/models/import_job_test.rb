require 'test_helper'

class ImportJobTest < ActiveSupport::TestCase
  let(:repository) { create(:git_repository) }
  let(:code_set) { create(:code_set, repository: repository) }

  describe 'progress_message' do
    it 'should return required message' do
      job = ImportJob.new(repository: repository)
      job.progress_message.must_equal 'Step 2 of 3: Importing source code into database'
    end
  end

  describe 'work' do
    it 'must call import on code_set' do
      import_job = ImportJob.new(code_set: code_set)

      code_set.stubs(:update)
      code_set.expects(:import)

      import_job.work(&proc {})
    end
  end

  describe 'after_completed' do
    it 'must create a SlocJob' do
      import_job = ImportJob.new(code_set: code_set)

      assert_difference 'SlocJob.count' do
        import_job.after_completed
      end
    end
  end
end
