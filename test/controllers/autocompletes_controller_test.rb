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

  describe 'licenses' do
    it 'must render valid licenses json' do
      license_1 = create(:license, nice_name: 'ACMIT')
      create(:license, nice_name: 'ACBSD')
      license_3 = create(:license, nice_name: 'ACMit v2')

      get :licenses, term: 'acmit', format: :json

      must_respond_with :ok
      resp = JSON.parse(response.body)
      resp.length.must_equal 2
      [resp[0]['id'].to_i, resp[1]['id'].to_i].sort.must_equal [license_1.id, license_3.id].sort
      [resp[0]['nice_name'], resp[1]['nice_name']].sort.must_equal [license_1.nice_name, license_3.nice_name].sort
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
  end
end
