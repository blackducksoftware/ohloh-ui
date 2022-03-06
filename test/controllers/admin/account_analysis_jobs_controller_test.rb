# frozen_string_literal: true

require 'test_helper'

class Admin::AccountAnalysisJobsControllerTest < ActionController::TestCase
  let(:admin) { create(:admin) }
  let(:account) { create(:account) }
  before { login_as admin }

  describe '#index' do
    it 'should render index template' do
      get :index, params: { account_id: account.login }
      assert_response :ok
      assert_template :index
    end

    it 'should have action items' do
      get :index, params: { account_id: account.login }
      assert_select "a[href='/admin/accounts/#{account.login}/account_analysis_jobs/manually_schedule']", true
    end
  end

  describe '#manually_schedule' do
    it 'should create a account_analysis job for the account' do
      assert_difference 'AccountAnalysisJob.count' do
        get :manually_schedule, params: { account_id: account.login }
      end
    end

    it 'should redirect to index' do
      get :manually_schedule, params: { account_id: account.login }
      assert_redirected_to admin_account_account_analysis_jobs_path(account)
    end
  end
end
