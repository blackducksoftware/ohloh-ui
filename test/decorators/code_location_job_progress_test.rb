require 'test_helper'

class CodeLocationJobProgressTest < ActiveSupport::TestCase
  let(:code_location) { code_location_stub_with_id }
  let(:enlistment) { create(:enlistment, code_location_id: code_location.id) }
  let(:repo_progress) { CodeLocationJobProgress.new(enlistment) }

  before do
    enlistment.stubs(:code_location).returns(code_location)
    @job = create(:fetch_job, code_location_id: code_location.id)
  end

  describe 'message' do
    it 'should return waiting message' do
      repo_progress.message.must_equal 'Step 1 of 3: Downloading source code history (Waiting in queue)'
    end

    it 'should return running message' do
      @job.update_columns(status: 1)
      repo_progress.message.must_equal 'Step 1 of 3: Downloading source code history (Running)'
    end

    it 'should return running with step message' do
      @job.update_columns(status: 1, current_step: 2, max_steps: 3)
      repo_progress.message.must_equal 'Step 1 of 3: Downloading source code history (Running 2/3)'
    end

    it 'should return failed message' do
      @job.update_columns(status: 3)
      repo_progress.message.must_equal 'Step 1 of 3: Downloading source code history (Failed)'
    end

    it 'should return failed with step message' do
      @job.update_columns(status: 3, current_step_at: Time.current - 2.days)
      repo_progress.message.must_equal 'Step 1 of 3: Downloading source code history (Failed 2 days ago.)'
    end

    it 'should return no job' do
      @job.update_columns(status: 5)
      repo_progress.message.must_equal 'No job is scheduled.'
    end

    it 'should return blocked job message' do
      @job.update_columns(status: 5)
      new_code_location = code_location_stub_with_id
      create(:fetch_job, code_location_id: new_code_location.id)
      create(:enlistment, project: enlistment.project, code_location_id: new_code_location.id)

      repo_progress.message.must_equal I18n.t('repositories.job_progress.blocked_by', status: 'waiting')
    end

    it 'should return update complete message' do
      @job.update_columns(status: 5)
      repo_progress.stubs(:sloc_set_code_set_time).returns(Time.current - 2.days)
      repo_progress.message.must_equal 'Open Hub update completed 2 days ago.'
    end
  end
end
