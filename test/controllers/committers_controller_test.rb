# frozen_string_literal: true

require 'test_helper'
require 'support/unclaimed_controller_test'

class CommittersControllerTest < ActionController::TestCase
  before do
    Person.destroy_all
    @person = create(:person)
    @project1 = create(:project)
    @project2 = create(:project)
    create(:name_fact, analysis_id: @project1.best_analysis_id, name_id: @person.name.id)
    create(:name_fact, analysis_id: @project2.best_analysis_id, name_id: @person.name.id)
  end

  describe 'index' do
    it 'should return list of unclaimed people' do
      get :index
      _(assigns(:unclaimed_people)).must_equal [[@person.name_id, [@person]]]
      _(assigns(:unclaimed_people_count)).must_equal 1
      assert_response :ok
      assert_template :index
    end

    it 'should filter by name' do
      get :index, params: { query: @person.name.name }
      _(assigns(:unclaimed_people)).must_equal [[@person.name_id, [@person]]]
      _(assigns(:unclaimed_people_count)).must_equal 1
      assert_response :ok
      assert_template :index
    end

    it 'must limit queried results when it exceeds OBJECT_MEMORY_CAP' do
      UnclaimedControllerTest.limit_by_memory_cap(self) do |people, unclaimed_tile_limit|
        _(people.length).must_equal unclaimed_tile_limit
      end
    end

    it 'must limit results when it exceeds OBJECT_MEMORY_CAP' do
      UnclaimedControllerTest.limit_by_memory_cap(self, with_query: false) do |people, unclaimed_tile_limit|
        _(people.length).must_equal unclaimed_tile_limit
      end
    end

    it 'should not return if query is not found' do
      get :index, params: { query: 'Im banana' }
      _(assigns(:unclaimed_people)).must_be_empty
      _(assigns(:unclaimed_people_count)).must_equal 0
      assert_response :ok
      assert_template :index
    end

    it 'must set title to Open Hub when no query string is present' do
      get :index

      assert_select 'title', I18n.t('committers.title', text: '')
    end

    it 'must set title to query string when it is present' do
      query = Faker::Lorem.word

      get :index, params: { query: query }

      assert_select 'title', I18n.t('committers.title', text: ": #{query}")
    end

    it 'must set title with current_user name when flow is account' do
      account = create(:account)
      login_as account
      query = Faker::Lorem.word

      get :index, params: { query: query, flow: :account }

      assert_select 'title', I18n.t('committers.user_title', name: account.name)
    end
  end

  describe 'show' do
    it 'should return unclaimed person' do
      get :show, params: { id: @person.name.id }
      _(assigns(:people).count).must_equal 1
      _(assigns(:people).first).must_equal @person
      assert_response :ok
      assert_template :show
    end

    it 'must limit results by OBJECT_MEMORY_CAP' do
      limit = 3
      original_object_memory_cap = OBJECT_MEMORY_CAP
      Object.send(:remove_const, 'OBJECT_MEMORY_CAP')
      Object.const_set('OBJECT_MEMORY_CAP', limit)

      name = create(:name_with_fact)
      name_fact = name.name_facts.first
      create_list(:person, limit + 1, name: name, name_fact: name_fact)

      get :show, params: { id: name.id }

      _(assigns(:people).count).must_equal OBJECT_MEMORY_CAP

      Object.send(:remove_const, 'OBJECT_MEMORY_CAP')
      Object.const_set('OBJECT_MEMORY_CAP', original_object_memory_cap)
    end

    it 'should raise if invalid committer' do
      get :show, params: { id: 989_898 }
      _(assigns(:people)).must_be_nil
      assert_response :not_found
    end
  end

  describe 'claim' do
    it 'must be logged in to claim projects' do
      post :claim, params: { id: @person.name.id }
      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'should render claim for project ids' do
      login_as create(:account)
      post :claim, params: { project_ids: [@project1.id, @project2.id], id: @person.name.id }
      _(assigns(:positions).count).must_equal 2
      _(assigns(:positions).map(&:project_id).sort).must_equal [@project1.id, @project2.id].sort
      assert_response :ok
      assert_template :claim
    end
  end

  describe 'save_claim' do
    it 'must be logged in to create a position' do
      post :save_claim, params: { id: @person.name.id }
      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'must create a position for projects' do
      account = create(:account)
      login_as account
      assert_difference 'Position.count', 2 do
        post :save_claim, params: { id: @person.name.id, positions: [
          { project_id: @project1.id, title: 'project_1_title', description: 'proj_1_desc' },
          { project_id: @project2.id, title: 'project_2_title', description: 'proj_2_desc' }
        ] }
        _(assigns(:positions)).must_be_empty
        assert_response :redirect
        assert_redirected_to account_positions_url(account)
      end
    end

    it 'must render claim if position fails' do
      Project.any_instance.stubs(:positions).raises(ActiveRecord::RecordInvalid)
      login_as create(:account)
      assert_no_difference 'Position.count' do
        post :save_claim, params: { id: @person.name.id, positions: [
          { project_id: @project1.id, title: 'project_1_title', description: 'proj_1_desc' },
          { project_id: @project2.id, title: 'project_2_title', description: 'proj_2_desc' }
        ] }
        assert_response :ok
        assert_template :claim
        _(assigns(:positions).count).must_equal 2
      end
    end
  end
end
