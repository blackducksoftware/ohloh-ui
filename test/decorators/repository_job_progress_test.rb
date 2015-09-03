require 'test_helper'

class RepositoryJobProgressTest < ActiveSupport::TestCase
  let(:enlistment) { create(:enlistment) }
  let(:repo_progress) { RepositoryJobProgress.new(enlistment) }
  let(:job) { enlistment.repository.jobs.incomplete.first }

  describe 'message' do
    it 'should return waiting message' do
      repo_progress.message.must_equal 'Step 1 of 3: Downloading source code history (Waiting in queue)'
    end

    it 'should return running message' do
      job.update_columns(status: 1)
      repo_progress.message.must_equal 'Step 1 of 3: Downloading source code history (Running)'
    end

    it 'should return running with step message' do
      job.update_columns(status: 1, current_step: 2, max_steps: 3)
      repo_progress.message.must_equal 'Step 1 of 3: Downloading source code history (Running 2/3)'
    end

    it 'should return failed message' do
      job.update_columns(status: 3)
      repo_progress.message.must_equal 'Step 1 of 3: Downloading source code history (Failed)'
    end

    it 'should return failed with step message' do
      job.update_columns(status: 3, current_step_at: Time.current - 2.days)
      repo_progress.message.must_equal 'Step 1 of 3: Downloading source code history (Failed 2 days ago.)'
    end

    it 'should return no job' do
      job.update_columns(status: 5)
      repo_progress.message.must_equal 'No job is scheduled.'
    end

    it 'should return blocked job message' do
      job.update_columns(status: 5)
      repository = create(:repository)
      repository.enlistments.first.update_columns(project_id: enlistment.project_id)

      repo_progress.message.must_equal I18n.t('repositories.job_progress.blocked_by', status: 'waiting')
    end

    it 'should return update complete message' do
      job.update_columns(status: 5)
      repo_progress.stubs(:sloc_set_logged_at).returns(Time.current - 2.days)
      repo_progress.message.must_equal 'Open Hub update completed 2 days ago.'
    end
  end
end
