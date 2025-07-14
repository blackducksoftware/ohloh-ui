# frozen_string_literal: true

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
      _(repo_progress.message).must_equal 'Step 1 of 3: Downloading source code history (Waiting in queue)'
    end

    it 'should return waiting message when its queued' do
      # Code location has same updated time as best_analysis. Hence we should see job progress.
      code_location.cl_update_event_time = 1.day.ago
      enlistment.project.best_analysis.update! updated_on: code_location.cl_update_event_time
      @job.update_columns(status: 2)

      _(repo_progress.message).must_equal 'Step 1 of 3: Downloading source code history (Waiting in queue)'
    end

    it 'should return running message' do
      # Code location is stale. Hence we should see job progress.
      code_location.cl_update_event_time = 2.days.ago
      enlistment.project.best_analysis.update! updated_on: 1.day.ago
      @job.update_columns(status: 1)

      _(repo_progress.message).must_equal 'Step 1 of 3: Downloading source code history (Running)'
    end

    it 'should return running with step message' do
      @job.update_columns(status: 1, current_step: 2, max_steps: 3)
      _(repo_progress.message).must_equal 'Step 1 of 3: Downloading source code history (Running 2/3)'
    end

    it 'should return failed message' do
      @job.update_columns(status: 3)
      _(repo_progress.message).must_equal 'Step 1 of 3: Downloading source code history (Failed)'
    end

    it 'should return failed with step message' do
      @job.update_columns(status: 3, current_step_at: 2.days.ago)
      _(repo_progress.message).must_equal 'Step 1 of 3: Downloading source code history (Failed 2 days ago.)'
    end

    it 'should return no job' do
      @job.update_columns(status: 5)
      _(repo_progress.message).must_equal 'No job is scheduled.'
    end

    it 'must return code_location fetched time if it has been updated since the last analysis' do
      code_location_updated_time = 5.hours.ago
      code_location.cl_update_event_time = code_location_updated_time
      enlistment.project.best_analysis.update! updated_on: 1.day.ago

      _(repo_progress.message).must_equal 'Open Hub update completed about 5 hours ago.'
    end

    it 'should return blocked job message' do
      @job.update_columns(status: 5)
      new_code_location = code_location_stub_with_id
      create(:fetch_job, code_location_id: new_code_location.id)
      create(:enlistment, project: enlistment.project, code_location_id: new_code_location.id)

      _(repo_progress.message).must_equal 'Blocked by waiting job'
    end

    it 'should return update complete message' do
      @job.update_columns(status: 5)
      repo_progress.stubs(:sloc_set_code_set_time).returns(2.days.ago)
      _(repo_progress.message).must_equal 'Open Hub update completed 2 days ago.'
    end

    it 'should return waiting message when job is restarted' do
      @job.update_columns(status: 4)
      _(repo_progress.message).must_equal 'Step 1 of 3: Downloading source code history (Waiting in queue)'
    end
  end
end
