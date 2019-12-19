# frozen_string_literal: true

require 'test_helper'

describe 'Admin::VitaJobsController' do
  let(:admin) { create(:admin) }
  let(:account) { create(:account) }
  before { login_as admin }

  describe '#index' do
    it 'should render index template' do
      get :index, account_id: account.login
      must_respond_with :ok
      must_render_template :index
    end

    it 'should have action items' do
      get :index, account_id: account.login
      must_select "a[href='/admin/accounts/#{account.login}/vita_jobs/manually_schedule']", true
    end
  end

  describe '#manually_schedule' do
    it 'should create a vita job for the account' do
      assert_difference 'VitaJob.count' do
        get :manually_schedule, account_id: account.login
      end
    end

    it 'should redirect to index' do
      get :manually_schedule, account_id: account.login
      must_redirect_to admin_account_vita_jobs_path(account)
    end
  end
end
