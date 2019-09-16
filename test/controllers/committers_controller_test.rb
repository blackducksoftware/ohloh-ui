# frozen_string_literal: true

require 'test_helper'
require 'support/unclaimed_controller_test'

describe 'CommittersControllerTest' do
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
      assigns(:unclaimed_people).must_equal [[@person.name_id, [@person]]]
      assigns(:unclaimed_people_count).must_equal 1
      must_respond_with :ok
      must_render_template :index
    end

    it 'should filter by name' do
      get :index, query: @person.name.name
      assigns(:unclaimed_people).must_equal [[@person.name_id, [@person]]]
      assigns(:unclaimed_people_count).must_equal 1
      must_respond_with :ok
      must_render_template :index
    end

    it 'must limit queried results when it exceeds OBJECT_MEMORY_CAP' do
      UnclaimedControllerTest.limit_by_memory_cap(self)
    end

    it 'must limit results when it exceeds OBJECT_MEMORY_CAP' do
      UnclaimedControllerTest.limit_by_memory_cap(self, false)
    end

    it 'should not return if query is not found' do
      get :index, query: 'Im banana'
      assigns(:unclaimed_people).must_be_empty
      assigns(:unclaimed_people_count).must_equal 0
      must_respond_with :ok
      must_render_template :index
    end

    it 'must set title to Open Hub when no query string is present' do
      get :index

      must_select 'title', I18n.t('committers.title', text: '')
    end

    it 'must set title to query string when it is present' do
      query = Faker::Lorem.word

      get :index, query: query

      must_select 'title', I18n.t('committers.title', text: ": #{query}")
    end

    it 'must set title with current_user name when flow is account' do
      account = create(:account)
      login_as account
      query = Faker::Lorem.word

      get :index, query: query, flow: :account

      must_select 'title', I18n.t('committers.user_title', name: account.name)
    end
  end

  describe 'show' do
    it 'should return unclaimed person' do
      get :show, id: @person.name.id
      assigns(:people).count.must_equal 1
      assigns(:people).first.must_equal @person
      must_respond_with :ok
      must_render_template :show
    end

    it 'must limit results by OBJECT_MEMORY_CAP' do
      limit = 3
      original_object_memory_cap = OBJECT_MEMORY_CAP
      Object.send(:remove_const, 'OBJECT_MEMORY_CAP')
      Object.const_set('OBJECT_MEMORY_CAP', limit)

      name = create(:name_with_fact)
      name_fact = name.name_facts.first
      create_list(:person, limit + 1, name: name, name_fact: name_fact)

      get :show, id: name.id

      assigns(:people).count.must_equal OBJECT_MEMORY_CAP

      Object.send(:remove_const, 'OBJECT_MEMORY_CAP')
      Object.const_set('OBJECT_MEMORY_CAP', original_object_memory_cap)
    end

    it 'should raise if invalid committer' do
      get :show, id: 989_898
      assigns(:people).must_be_nil
      must_respond_with :not_found
    end
  end

  describe 'claim' do
    it 'must be logged in to claim projects' do
      post :claim, id: @person.name.id
      must_respond_with :redirect
      must_redirect_to new_session_path
    end

    it 'should render claim for project ids' do
      login_as create(:account)
      post :claim, project_ids: [@project1.id, @project2.id], id: @person.name.id
      assigns(:positions).count.must_equal 2
      assigns(:positions).map(&:project_id).sort.must_equal [@project1.id, @project2.id].sort
      must_respond_with :ok
      must_render_template :claim
    end
  end

  describe 'save_claim' do
    it 'must be logged in to create a position' do
      post :save_claim, id: @person.name.id
      must_respond_with :redirect
      must_redirect_to new_session_path
    end

    it 'must create a position for projects' do
      account = create(:account)
      login_as account
      assert_difference 'Position.count', 2 do
        post :save_claim, id: @person.name.id, positions: [
          { project_id: @project1.id, title: 'project_1_title', description: 'proj_1_desc' },
          { project_id: @project2.id, title: 'project_2_title', description: 'proj_2_desc' }
        ]
        assigns(:positions).must_be_empty
        must_respond_with :redirect
        must_redirect_to account_positions_url(account)
      end
    end

    it 'must render claim if position fails' do
      Project.any_instance.stubs(:positions).raises(ActiveRecord::RecordInvalid)
      login_as create(:account)
      assert_no_difference 'Position.count' do
        post :save_claim, id: @person.name.id, positions: [
          { project_id: @project1.id, title: 'project_1_title', description: 'proj_1_desc' },
          { project_id: @project2.id, title: 'project_2_title', description: 'proj_2_desc' }
        ]
        must_respond_with :ok
        must_render_template :claim
        assigns(:positions).count.must_equal 2
      end
    end
  end
end
