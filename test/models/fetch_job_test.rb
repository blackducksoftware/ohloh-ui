require 'test_helper'

class FetchJobTest < ActiveSupport::TestCase
  let(:svn_repository) { create(:svn_repository) }
  let(:code_set) { create(:code_set, repository: svn_repository, as_of: Faker::Number.number(2)) }

  describe 'progress_message' do
    it 'should return required message' do
      job = FetchJob.new(repository: svn_repository)
      job.progress_message.must_equal 'Step 1 of 3: Downloading source code history'
    end
  end

  describe 'work' do
    it 'must save repository if it is an svn_repository without branch_name' do
      job = FetchJob.new(repository: svn_repository, code_set: code_set)
      svn_repository.update!(branch_name: nil)
      svn_repository.expects(:save)
      code_set.expects(:fetch)
      job.work(&proc {})
    end
  end

  describe 'after_completed' do
    it 'must create a fetch job when code_set.as_of is null' do
      code_set.update!(as_of: nil)
      job = FetchJob.create(repository: svn_repository, code_set: code_set)

      assert_difference 'ImportJob.count' do
        job.after_completed
      end
    end

    it 'must create a sloc job when code_set has not sloc_set' do
      code_set.best_sloc_set.must_be_nil
      job = FetchJob.create(repository: svn_repository, code_set: code_set)

      assert_difference 'SlocJob.count' do
        job.after_completed
      end
    end

    it 'must update best_sloc_set logged_at' do
      Project.any_instance.stubs(:ensure_job)
      sloc_set = create(:sloc_set, code_set: code_set)
      code_set.update!(best_sloc_set: sloc_set)

      code_set.reload
      code_set.best_sloc_set.logged_at.must_be_nil

      job = FetchJob.create(repository: svn_repository, code_set: code_set, logged_at: Faker::Time.backward)

      code_set.reload.best_sloc_set.logged_at.must_be_nil
      job.after_completed
      code_set.reload.best_sloc_set.logged_at.must_equal job.logged_at
    end
  end
end
