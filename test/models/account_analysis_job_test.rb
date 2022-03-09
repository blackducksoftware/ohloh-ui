# frozen_string_literal: true

require 'test_helper'

class AccountAnalysisJobTest < ActiveSupport::TestCase
  let(:account) { create(:account) }
  let(:stub_time) { Time.stubs(:now).returns(Time.mktime(2015, 1, 1)) }

  it 'should create account_analysis job' do
    _(AccountAnalysisJob.where(account_id: account.id).count).must_equal 0
    AccountAnalysisJob.schedule_account_analysis(account)
    _(AccountAnalysisJob.where(account_id: account.id).count).must_equal 1
  end

  it 'should create account_analysis job with wait time' do
    Time.stubs(:now).returns(stub_time)
    AccountAnalysisJob.schedule_account_analysis(account, 10.minutes)
    account_analysis_jobs = AccountAnalysisJob.where(account_id: account.id)
    _(account_analysis_jobs.count).must_equal 1
    _(account_analysis_jobs.first.wait_until).must_equal Time.current + 10.minutes
  end

  it 'should update job if exist' do
    Time.stubs(:now).returns(stub_time)
    _(AccountAnalysisJob.where(account_id: account.id).count).must_equal 0
    AccountAnalysisJob.schedule_account_analysis(account)
    AccountAnalysisJob.schedule_account_analysis(account, 5.minutes)
    account_analysis_jobs = AccountAnalysisJob.where(account_id: account.id)
    _(account_analysis_jobs.count).must_equal 1
    _(account_analysis_jobs.first.wait_until).must_equal Time.current + 5.minutes
  end

  it 'schedule_account_analysis_for_project' do
    position = create_position
    AccountAnalysisJob.expects(:schedule_account_analysis)
    AccountAnalysisJob.schedule_account_analysis_for_project(position.project)
  end

  describe 'progress_message' do
    it 'should return required message' do
      job = AccountAnalysisJob.create(account: create(:account))
      _(job.progress_message).must_equal "Creating account analysis for #{job.account.name}"
    end
  end
end
