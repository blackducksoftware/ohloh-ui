# frozen_string_literal: true

require 'test_helper'

class Admin::DashboardControllerTest < ActionController::TestCase
  let(:admin) { create(:admin) }
  before do
    login_as admin
    create(:load_average)
  end

  describe '#index' do
    it 'should render index template' do
      get :index
      assert_response :ok
      assert_template :index
      assert_template '_overview'
      assert_template '_job_overview'
    end

    it 'should show last run time of check CII projects cronjob' do
      get :index
      _(response.body).must_match 'Last ran CII Projects'
    end
  end
end
