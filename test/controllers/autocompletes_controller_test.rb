# frozen_string_literal: true

require 'test_helper'

describe 'AutocompletesController' do
  describe 'account' do
    it 'should return account hash' do
      account = create(:account)
      xhr :get, :account, term: account.login
      must_respond_with :ok

      result = JSON.parse(response.body)
      result.first['login'].must_equal account.login
      result.first['value'].must_equal account.login
      result.first['name'].must_equal account.name
    end

    it 'should gracefully handle empty terms' do
      xhr :get, :account
      must_respond_with :ok

      result = JSON.parse(response.body)
      result.length.must_equal 0
    end
  end

  describe 'projects_for_stack' do
    it 'must render a valid project json' do
      account = create(:account)
      login_as account
      project1 = create(:project, name: 'Foo')
      project2 = create(:project, name: 'Foobar')
      create(:project, name: 'Goobaz')

      stack = create(:stack, account: account)
      stack.projects << project1
      stack.save!

      get :projects_for_stack, id: stack.id, account_id: account.id, term: 'foo', format: :json

      must_respond_with :ok
      resp = JSON.parse(response.body)
      resp.length.must_equal 1
      resp[0]['id'].must_equal project2.id
      resp[0]['value'].must_equal project2.name
    end
  end

  describe 'project' do
    it 'must render a valid project json' do
      project1 = create(:project, name: 'Foo')
      project2 = create(:project, name: 'Foobar')
      create(:project, name: 'Goobaz')

      get :project, term: 'foo', format: :json

      must_respond_with :ok
      resp = JSON.parse(response.body)
      resp.length.must_equal 2
      resp[0]['id'].must_equal project1.to_param
      resp[0]['value'].must_equal project1.name
      resp[1]['id'].must_equal project2.to_param
      resp[1]['value'].must_equal project2.name
    end

    it 'must exclude a given project_id' do
      create(:project, name: 'Foo')
      project2 = create(:project, name: 'Foo-excluded')
      create(:project, name: 'Foobar')
      create(:project, name: 'Goobaz')

      get :project, term: 'foo', exclude_project_id: project2.id, format: :json

      resp = JSON.parse(response.body)
      resp.length.must_equal 2
      resp.map { |hsh| hsh['value'] }.must_equal %w[Foo Foobar]
    end

    it 'must handle a blank exclude_project_id' do
      create(:project, name: 'Foobar')
      create(:project, name: 'Foo')

      get :project, term: 'foo', exclude_project_id: '', format: :json

      resp = JSON.parse(response.body)
      resp.length.must_equal 2
    end

    it 'must order projects by name length' do
      create(:project, name: 'Foobar')
      create(:project, name: 'Foo')

      get :project, term: 'foo', format: :json

      resp = JSON.parse(response.body)
      resp.map { |hsh| hsh['value'] }.must_equal %w[Foo Foobar]
    end
  end

  describe 'project_duplicates' do
    it 'must render project duplicates json' do
      create(:project, name: 'Foobar', user_count: 10)
      create(:project, name: 'Foo', user_count: 13)

      get :project_duplicates, term: 'foo', format: :json

      resp = JSON.parse(response.body)
      resp.map { |hsh| hsh['value'] }.must_equal %w[Foo Foobar]
    end
  end

  describe 'licenses' do
    it 'must render valid licenses json' do
      license1 = create(:license, name: 'ACMIT')
      create(:license, name: 'ACBSD')
      license3 = create(:license, name: 'ACMit v2')

      get :licenses, term: 'acmit', format: :json

      must_respond_with :ok
      resp = JSON.parse(response.body)
      resp.length.must_equal 2
      [resp[0]['id'].to_i, resp[1]['id'].to_i].sort.must_equal [license1.id, license3.id].sort
      [resp[0]['name'], resp[1]['name']].sort.must_equal [license1.name, license3.name].sort
    end
  end

  describe 'contributions' do
    it 'must render name facts json' do
      project = create(:project)
      name1 = create(:name, name: 'test1')
      name2 = create(:name, name: 'test2')
      create(:name_fact, name: name1, analysis: project.best_analysis)
      create(:name_fact, name: name2, analysis: project.best_analysis)

      get :contributions, term: 'test', project: project.name.to_s

      must_respond_with :ok
      result = JSON.parse(response.body)
      result.length.must_equal 2
      result.first.must_equal name1.name
      result.last.must_equal name2.name
    end

    it 'must render empty text if project name is empty' do
      get :contributions, term: 'test'

      must_respond_with :ok
      response.body.must_equal ''
    end
  end

  describe 'tags' do
    it 'must render valid tags json' do
      project = create(:project)
      create(:tagging, tag: create(:tag, name: 'c'), taggable: project)
      create(:tagging, tag: create(:tag, name: 'algol'), taggable: project)
      create(:tagging, tag: create(:tag, name: 'c++'), taggable: project)

      get :tags, term: 'C', format: :json

      must_respond_with :ok
      resp = JSON.parse(response.body)
      resp.length.must_equal 2
      [resp[0], resp[1]].sort.must_equal ['c', 'c++']
    end

    it 'should not fail if project_id is blank' do
      get :tags, project_id: '', format: :json
      must_respond_with :ok
    end
  end
end
