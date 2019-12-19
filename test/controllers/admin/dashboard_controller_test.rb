# frozen_string_literal: true

require 'test_helper'

describe 'Admin::DashboardController' do
  let(:admin) { create(:admin) }
  before do
    login_as admin
    create(:load_average)
  end

  describe '#index' do
    it 'should render index template' do
      get :index
      must_respond_with :ok
      must_render_template :index
      must_render_template '_overview'
      must_render_template '_job_overview'
    end

    it 'should show last run time of check CII projects cronjob' do
      get :index
      response.body.must_match 'Last ran CII Projects'
    end
  end
end
