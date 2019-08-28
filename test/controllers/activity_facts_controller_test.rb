# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/xml_parsing_helpers'

describe 'ActivityFactsControllerTest' do
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

      get :index, format: 'xml', project_id: project.id, analysis_id: 'latest', api_key: client_id
      xml = xml_hash(@response.body)

      must_respond_with :ok
      xml['response']['status'].must_equal 'success'
      xml['response']['items_returned'].must_equal '5'
      xml['response']['items_available'].must_equal '5'
      xml['response']['first_item_position'].must_equal '0'
      xml['response']['result']['activity_fact'].size.must_equal 5
      xml['response']['result']['activity_fact'].reverse.each_with_index do |fact, index|
        fact['month'].must_equal xml_time(Date.current - (index + 1).months)
      end
    end

    it 'should respond with activity_facts analysis id is specified' do
      get :index, format: 'xml', project_id: project.id, analysis_id: analysis.id, api_key: client_id
      xml = xml_hash(@response.body)

      must_respond_with :ok
      xml['response']['status'].must_equal 'success'
      xml['response']['items_returned'].must_equal '5'
      xml['response']['items_available'].must_equal '5'
      xml['response']['first_item_position'].must_equal '0'
      xml['response']['result']['activity_fact'].size.must_equal 5
      xml['response']['result']['activity_fact'].reverse.each_with_index do |fact, index|
        fact['month'].must_equal xml_time(Date.current - (index + 1).months)
      end
    end

    it 'must render projects/deleted when project is deleted' do
      project.update!(deleted: true)

      get :index, format: 'xml', project_id: project.id, analysis_id: analysis.id, api_key: client_id

      must_render_template 'deleted'
    end

    it 'should respond with unauthorized if api_key is invalid' do
      get :index, format: 'xml', project_id: project.id, analysis_id: analysis.id, api_key: 'dummy_key'
      xml = xml_hash(@response.body)

      must_respond_with :bad_request
      xml['error']['message'].must_equal I18n.t(:invalid_api_key)
    end
  end
end
