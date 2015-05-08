require 'test_helper'
require 'test_helpers/xml_parsing_helpers'

describe 'SizeFactsControllerTest' do
  let(:account) { create(:account) }
  let(:analysis) { create(:analysis, min_month: Date.today - 5.months) }
  let(:project) { create(:project) }
  let(:api_key) { create(:api_key, account_id: account.id, daily_limit: 100) }
  let(:client_id) { api_key.oauth_application.uid }

  before do
    AllMonth.delete_all
    (1..5).to_a.each do |value|
      create(:all_month, month: Date.today - value.months)
      create(:activity_fact, month: Date.today - value.months, analysis_id: analysis.id,
                             code_added: 10, code_removed: 7, comments_added: 10, comments_removed: 7)
    end
  end

  describe 'index' do
    it 'should respond with size_facts for latest analysis' do
      project.update_column(:best_analysis_id, analysis.id)

      get :index, format: 'xml', project_id: project.id, analysis_id: 'latest', api_key: client_id
      xml = xml_hash(@response.body)

      must_respond_with :ok
      xml['response']['status'].must_equal 'success'
      xml['response']['items_returned'].must_equal '4'
      xml['response']['items_available'].must_equal '4'
      xml['response']['first_item_position'].must_equal '0'
      xml['response']['result']['size_fact'].size.must_equal 4
      xml['response']['result']['size_fact'].reverse.each_with_index do |fact, index|
        code_value = ((4 - index) * 3).to_s
        commits_value = ((400 - (index * 100))).to_s
        month_value = (4 - index).to_s

        fact['code'].must_equal code_value
        fact['comments'].must_equal code_value
        fact['blanks'].must_equal '0'
        fact['comment_ratio'].must_equal '0.5'
        fact['commits'].must_equal commits_value
        fact['man_months'].must_equal month_value
        fact['month'].must_equal xml_time Date.today - (index + 2).months
      end
    end

    it 'should respond with size_facts analysis id is specified' do
      get :index, format: 'xml', project_id: project.id, analysis_id: analysis.id, api_key: client_id
      xml = xml_hash(@response.body)

      must_respond_with :ok
      xml['response']['status'].must_equal 'success'
      xml['response']['items_returned'].must_equal '4'
      xml['response']['items_available'].must_equal '4'
      xml['response']['first_item_position'].must_equal '0'
      xml['response']['result']['size_fact'].size.must_equal 4
      xml['response']['result']['size_fact'].reverse.each_with_index do |fact, index|
        code_value = ((4 - index) * 3).to_s
        commits_value = ((400 - (index * 100))).to_s
        month_value = (4 - index).to_s

        fact['code'].must_equal code_value
        fact['comments'].must_equal code_value
        fact['blanks'].must_equal '0'
        fact['comment_ratio'].must_equal '0.5'
        fact['commits'].must_equal commits_value
        fact['man_months'].must_equal month_value
        fact['month'].must_equal xml_time Date.today - (index + 2).months
      end
    end

    it 'should respond with failure if project id deleted' do
      Project.any_instance.stubs(:deleted?).returns(true)

      get :index, format: 'xml', project_id: project.id, analysis_id: analysis.id, api_key: client_id
      xml = xml_hash(@response.body)

      must_respond_with :ok
      xml['response']['status'].must_equal I18n.t('projects.deleted.failed')
      xml['response']['error'].must_equal I18n.t('projects.deleted.message', name: project.name)
    end

    it 'should respond with failure if project id does not exist' do
      get :index, format: 'xml', project_id: 'not_available', analysis_id: analysis.id, api_key: client_id
      xml = xml_hash(@response.body)

      must_respond_with :not_found
      xml['error']['message'].must_equal I18n.t('four_oh_four')
    end

    it 'should respond with unauthorized if api_key is invalid' do
      get :index, format: 'xml', project_id: project.id, analysis_id: analysis.id, api_key: 'dummy_key'
      xml = xml_hash(@response.body)

      must_respond_with :unauthorized
      xml['error']['message'].must_equal I18n.t(:not_authorized)
    end
  end
end
