# frozen_string_literal: true

require 'test_helper'

class VitaJobTest < ActiveSupport::TestCase
  let(:account) { create(:account) }
  let(:stub_time) { Time.stubs(:now).returns(Time.mktime(2015, 1, 1)) }

  it 'should create vita job' do
    VitaJob.where(account_id: account.id).count.must_equal 0
    VitaJob.schedule_account_analysis(account)
    VitaJob.where(account_id: account.id).count.must_equal 1
  end

  it 'should create vita job with wait time' do
    Time.stubs(:now).returns(stub_time)
    VitaJob.schedule_account_analysis(account, 10.minutes)
    vita_jobs = VitaJob.where(account_id: account.id)
    vita_jobs.count.must_equal 1
    vita_jobs.first.wait_until.must_equal Time.current + 10.minutes
  end

  it 'should update job if exist' do
    Time.stubs(:now).returns(stub_time)
    VitaJob.where(account_id: account.id).count.must_equal 0
    VitaJob.schedule_account_analysis(account)
    VitaJob.schedule_account_analysis(account, 5.minutes)
    vita_jobs = VitaJob.where(account_id: account.id)
    vita_jobs.count.must_equal 1
    vita_jobs.first.wait_until.must_equal Time.current + 5.minutes
  end

  it 'schedule_account_analysis_for_project' do
    position = create_position
    VitaJob.expects(:schedule_account_analysis)
    VitaJob.schedule_account_analysis_for_project(position.project)
  end

  describe 'progress_message' do
    it 'should return required message' do
      job = VitaJob.create(account: create(:account))
      job.progress_message.must_equal "Creating vita for #{job.account.name}"
    end
  end
end
