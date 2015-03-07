require 'test_helper'

describe 'ActivityFactsControllerTest' do
  let(:account) { create(:account) }
  let(:analysis) { create(:analysis, min_month: Date.today - 5.months) }
  let(:project) { create(:project) }
  let(:api_key) { create(:api_key, account_id: account.id, daily_limit: 100) }

  def xml_time(date)
    Time.gm(date.year, date.month, date.day).xmlschema
  end

  def xml_hash(data)
    xml = Nokogiri::XML(data)
    Hash.from_xml(xml.to_s)
  end

  before do
    (1..5).to_a.each do |value|
      create(:all_month, month: Date.today - value.months)
      create(:activity_fact, month: Date.today - value.months, analysis_id: analysis.id)
    end
  end

  describe 'index' do
    it 'should respond with activity_facts for latest analysis' do
      project.update_column(:best_analysis_id, analysis.id)

      get :index, { format: 'xml', project_id: project.id, analysis_id: 'latest', api_key: api_key.key }
      xml = xml_hash(@response.body)

      must_respond_with :ok
      xml['response']['status'].must_equal 'success'
      xml['response']['items_returned'].must_equal '5'
      xml['response']['items_available'].must_equal '5'
      xml['response']['first_item_position'].must_equal '0'
      xml['response']['result']['activity_fact'].size.must_equal 5
      xml['response']['result']['activity_fact'].reverse.each_with_index do |fact, index|
        fact['month'].must_equal xml_time(Date.today - (index + 1).months)
      end
    end

    it 'should respond with activity_facts analysis id is specified' do
      get :index, { format: 'xml', project_id: project.id, analysis_id: analysis.id, api_key: api_key.key }
      xml = xml_hash(@response.body)

      must_respond_with :ok
      xml['response']['status'].must_equal 'success'
      xml['response']['items_returned'].must_equal '5'
      xml['response']['items_available'].must_equal '5'
      xml['response']['first_item_position'].must_equal '0'
      xml['response']['result']['activity_fact'].size.must_equal 5
      xml['response']['result']['activity_fact'].reverse.each_with_index do |fact, index|
        fact['month'].must_equal xml_time(Date.today - (index + 1).months)
      end
    end

    it 'should respond with failure if project id deleted' do
      Project.any_instance.stubs(:deleted?).returns(true)

      get :index, { format: 'xml', project_id: project.id, analysis_id: analysis.id, api_key: api_key.key }
      xml = xml_hash(@response.body)

      must_respond_with :ok
      xml['response']['status'].must_equal I18n.t('projects.deleted.failed')
      xml['response']['error'].must_equal I18n.t('projects.deleted.message', name: project.name)
    end

    it 'should respond with unauthorized if api_key is invalid' do
      get :index, { format: 'xml', project_id: project.id, analysis_id: analysis.id, api_key: 'dummy_key' }
      xml = xml_hash(@response.body)

      must_respond_with :unauthorized
      xml['error']['message'].must_equal I18n.t(:not_authorized)
    end
  end
end
