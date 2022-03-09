# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/xml_parsing_helpers'

class SizeFactsControllerTest < ActionController::TestCase
  let(:account) { create(:account) }
  let(:analysis) { create(:analysis) }
  let(:project) { create(:project) }
  let(:api_key) { create(:api_key, account_id: account.id, daily_limit: 100) }
  let(:client_id) { api_key.oauth_application.uid }

  before do
    AllMonth.delete_all
    (1..4).to_a.each do |value|
      create(:all_month, month: Date.current.at_beginning_of_month - value.months)
      create(:activity_fact, month: Date.current.at_beginning_of_month - value.months,
                             analysis_id: analysis.id, code_added: 10, code_removed: 7, comments_added: 10,
                             comments_removed: 7)
    end
  end

  describe 'index' do
    it 'should respond with size_facts for latest analysis' do
      project.update_column(:best_analysis_id, analysis.id)

      get :index, params: { format: 'xml', project_id: project.id, analysis_id: 'latest', api_key: client_id }
      xml = xml_hash(@response.body)

      assert_response :ok
      _(xml['response']['status']).must_equal 'success'
      _(xml['response']['items_returned']).must_equal '4'
      _(xml['response']['items_available']).must_equal '4'
      _(xml['response']['first_item_position']).must_equal '0'
      _(xml['response']['result']['size_fact'].size).must_equal 4
      xml['response']['result']['size_fact'].reverse.each do |fact|
        _(fact['code']).must_equal '3'
        _(fact['comments']).must_equal '3'
        _(fact['blanks']).must_equal '0'
        _(fact['comment_ratio']).must_equal '0.5'
        _(fact['commits']).must_equal '100'
        _(fact['man_months']).must_equal '1'
      end
    end

    it 'should respond with size_facts analysis id is specified' do
      get :index, params: { format: 'xml', project_id: project.id, analysis_id: analysis.id, api_key: client_id }
      xml = xml_hash(@response.body)

      assert_response :ok
      _(xml['response']['status']).must_equal 'success'
      _(xml['response']['items_returned']).must_equal '4'
      _(xml['response']['items_available']).must_equal '4'
      _(xml['response']['first_item_position']).must_equal '0'
      _(xml['response']['result']['size_fact'].size).must_equal 4
      xml['response']['result']['size_fact'].reverse.each do |fact|
        _(fact['code']).must_equal '3'
        _(fact['comments']).must_equal '3'
        _(fact['blanks']).must_equal '0'
        _(fact['comment_ratio']).must_equal '0.5'
        _(fact['commits']).must_equal '100'
        _(fact['man_months']).must_equal '1'
      end
    end

    it 'must render deleted if project is deleted' do
      project.update!(deleted: true, editor_account: account)

      get :index, params: { format: 'xml', project_id: project.id, analysis_id: analysis.id, api_key: client_id }

      assert_template 'deleted'
    end

    it 'should respond with failure if project id does not exist' do
      get :index, params: { format: 'xml', project_id: 'not_available', analysis_id: analysis.id, api_key: client_id }
      xml = xml_hash(@response.body)

      assert_response :not_found
      _(xml['error']['message']).must_equal I18n.t('four_oh_four')
    end

    it 'should respond with unauthorized if api_key is invalid' do
      get :index, params: { format: 'xml', project_id: project.id, analysis_id: analysis.id, api_key: 'dummy_key' }
      xml = xml_hash(@response.body)

      assert_response :bad_request
      _(xml['error']['message']).must_equal I18n.t(:invalid_api_key)
    end
  end
end
