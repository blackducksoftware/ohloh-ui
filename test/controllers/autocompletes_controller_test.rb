require 'test_helper'

describe 'AutocompletesController' do
  describe 'account' do
    it 'should return account hash' do
      xhr :get, :account, term: 'luck'

      result = JSON.parse(response.body)
      result.first['login'].must_equal 'user'
      result.first['value'].must_equal 'user'
      result.first['name'].must_equal 'user Luckey'
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
      resp.map { |hsh| hsh['value'] }.must_equal %w(Foo Foobar)
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
      resp.map { |hsh| hsh['value'] }.must_equal %w(Foo Foobar)
    end
  end
end
