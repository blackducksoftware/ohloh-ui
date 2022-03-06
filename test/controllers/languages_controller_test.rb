# frozen_string_literal: true

require 'test_helper'

class LanguagesControllerTest < ActionController::TestCase
  let(:date_range) { [3.months.ago, 2.months.ago, 1.month.ago, Date.current].map(&:beginning_of_month) }
  let(:create_all_months) { date_range.each { |date| create(:all_month, month: date) } }
  let(:client_id) { create(:api_key).oauth_application.uid }

  before { @language = create(:language, name: 'html', nice_name: 'html') }

  describe 'index' do
    it 'should return languages' do
      create(:language, name: 'c', nice_name: 'c')

      get :index
      assert_response :ok
      assert_template :index
      _(assigns(:languages).count).must_equal 2
      _(assigns(:languages).last).must_equal @language
    end

    it 'should filter by name' do
      get :index, params: { query: @language.nice_name }
      assert_response :ok
      assert_template :index
      _(assigns(:languages).count).must_equal 1
      _(assigns(:languages).first).must_equal @language
    end

    it 'should not return if invalid query' do
      get :index, params: { query: 'Im banana' }
      assert_response :ok
      assert_template :index
      _(assigns(:languages).count).must_equal 0
    end

    it 'must sort by nice_name by default' do
      create(:language, name: 'abc', nice_name: 'xyz')
      @language.update!(name: 'xyz', nice_name: 'abc')
      get :index
      assert_response :ok
      assert_template :index
      _(assigns(:languages).count).must_equal 2
      _(assigns(:languages).first).must_equal @language
    end

    it 'must sort by selected option' do
      create(:language, commits: 15)
      @language.update!(commits: 20)
      get :index, params: { sort: 'commits' }
      assert_response :ok
      assert_template :index
      _(assigns(:languages).count).must_equal 2
      _(assigns(:languages).first).must_equal @language
    end

    it 'should respond to xml request' do
      get :index, params: { format: :xml, api_key: client_id }
      assert_response :ok
      assert_template :index
      _(assigns(:languages).count).must_equal 1
      _(response.status).must_equal 200
    end
  end

  describe 'show' do
    it 'should load language facts' do
      language_fact = create(:language_fact, language: @language)
      get :show, params: { id: @language.name }
      assert_response :ok
      assert_template :show
      _(assigns(:language_facts).count).must_equal 1
      _(assigns(:language_facts).first).must_equal language_fact
    end

    it 'should accept show by id and redirect to by name' do
      language = create(:language)
      get :show, params: { id: language.id }
      assert_response :found
      assert_redirected_to language_path(language)
    end

    it 'should not load language_facts if xml request' do
      create(:language_fact, language: @language)
      get :show, params: { id: @language.name, format: :xml, api_key: client_id }
      assert_response :ok
      assert_template :show
      _(assigns(:language_facts)).must_be_nil
    end
  end

  describe 'chart' do
    it 'should render json data' do
      create_all_months
      get :chart, params: { language_name: @language.name }
      assert_response :ok

      response_data = JSON.parse(response.body)
      _(response_data['series'].count).must_equal 1
      _(response_data['series'].last['name']).must_equal @language.nice_name
    end

    it 'should support muliple language names' do
      create_all_months
      language = create(:language)
      create(:language_fact, language: @language, loc_changed: 25, month: 3.months.ago.beginning_of_month)
      create(:language_fact, language: language, loc_changed: 25, month: 3.months.ago.beginning_of_month)
      get :chart, params: { language_name: [@language.name, language.name] }
      assert_response :ok
      response_data = JSON.parse(response.body)
      _(response_data['series'].count).must_equal 2
      _(response_data['series'].first['data']).must_equal [50.0, 0.0, 0.0]
      _(response_data['series'].second['data']).must_equal [50.0, 0.0, 0.0]
    end

    it 'should support different measures' do
      create_all_months
      create(:language_fact, language: @language, commits: 25, month: 3.months.ago.beginning_of_month)
      get :chart, params: { language_name: @language.name, measure: 'commits' }
      assert_response :ok
      response_data = JSON.parse(response.body)
      _(response_data['series'].count).must_equal 1
      _(response_data['series'].first['data']).must_equal [100.0, 0.0, 0.0]
    end
  end

  describe 'compare' do
    it 'should compare languages' do
      language = create(:language)
      get :compare, params: { language_name: [@language.name, language.name] }
      assert_response :ok
      assert_template :compare
      _(assigns(:language_names).count).must_equal 2
    end

    it 'should return default languages if language is not present' do
      create(:language, name: 'java')
      create(:language, name: 'php')
      get :compare
      assert_response :ok
      assert_template :compare
      _(assigns(:language_names).count).must_equal 3
      _(assigns(:language_names)).must_equal %w[html java php]
    end
  end
end
