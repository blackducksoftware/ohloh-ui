# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/xml_parsing_helpers'

class ActivityFactsControllerTest < ActionController::TestCase
  let(:account) { create(:account) }
  let(:analysis) { create(:analysis, min_month: Date.current - 5.months) }
  let(:project) { create(:project) }
  let(:api_key) { create(:api_key, account_id: account.id, daily_limit: 100) }
  let(:client_id) { api_key.oauth_application.uid }

  before do
    (1..5).to_a.each do |value|
      create(:all_month, month: Date.current - value.months)
      create(:activity_fact, month: Date.current - value.months, analysis_id: analysis.id)
    end
  end

  describe 'index' do
    it 'should respond with activity_facts for latest analysis' do
      project.update_column(:best_analysis_id, analysis.id)

      get :index, params: { format: 'xml', project_id: project.id, analysis_id: 'latest', api_key: client_id }
      xml = xml_hash(@response.body)

      assert_response :ok
      _(xml['response']['status']).must_equal 'success'
      _(xml['response']['items_returned']).must_equal '5'
      _(xml['response']['items_available']).must_equal '5'
      _(xml['response']['first_item_position']).must_equal '0'
      _(xml['response']['result']['activity_fact'].size).must_equal 5
      xml['response']['result']['activity_fact'].reverse.each_with_index do |fact, index|
        _(fact['month']).must_equal xml_time(Date.current - (index + 1).months)
      end
    end

    it 'should respond with activity_facts analysis id is specified' do
      get :index, params: { format: 'xml', project_id: project.id, analysis_id: analysis.id, api_key: client_id }
      xml = xml_hash(@response.body)

      assert_response :ok
      _(xml['response']['status']).must_equal 'success'
      _(xml['response']['items_returned']).must_equal '5'
      _(xml['response']['items_available']).must_equal '5'
      _(xml['response']['first_item_position']).must_equal '0'
      _(xml['response']['result']['activity_fact'].size).must_equal 5
      xml['response']['result']['activity_fact'].reverse.each_with_index do |fact, index|
        _(fact['month']).must_equal xml_time(Date.current - (index + 1).months)
      end
    end

    it 'must render projects/deleted when project is deleted' do
      project.update!(deleted: true)

      get :index, params: { format: 'xml', project_id: project.id, analysis_id: analysis.id, api_key: client_id }

      assert_template 'deleted'
    end

    it 'should respond with unauthorized if api_key is invalid' do
      get :index, params: { format: 'xml', project_id: project.id, analysis_id: analysis.id, api_key: 'dummy_key' }
      xml = xml_hash(@response.body)

      assert_response :bad_request
      _(xml['error']['message']).must_equal I18n.t(:invalid_api_key)
    end
  end
end
