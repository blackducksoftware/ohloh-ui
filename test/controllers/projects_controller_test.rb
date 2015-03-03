require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  # autocomplete action
  it 'autocomplete should match correct projects' do
    project1 = create(:project, name: 'Foo')
    project2 = create(:project, name: 'Foobar')
    create(:project, name: 'Goobaz')
    get :autocomplete, term: 'foo', format: :json
    must_respond_with :ok
    resp = JSON.parse(response.body)
    resp.length.must_equal 2
    resp[0]['id'].must_equal project1.to_param
    resp[0]['value'].must_equal project1.name
    resp[1]['id'].must_equal project2.to_param
    resp[1]['value'].must_equal project2.name
  end

  # index
  it 'index should handle query param for unlogged users' do
    project1 = create(:project, name: 'Foo', description: Faker::Lorem.sentence(90))
    project2 = create(:project, name: 'Foobar', description: Faker::Lorem.sentence(90))
    project3 = create(:project, name: 'Goobaz', description: Faker::Lorem.sentence(90))
    login_as nil
    get :index, q: 'foo'
    must_respond_with :ok
    must_select "div.well#project_#{project1.id}", true
    must_select "div.well#project_#{project2.id}", true
    must_select "div.well#project_#{project3.id}", false
  end

  it 'index should handle query param that matches no project' do
    get :index, q: 'qwertyuioplkjhgfdsazxcvbnm'
    must_respond_with :ok
    must_select 'div.advanced_search_tips', true
  end

  it 'index should handle query param sorting by "new"' do
    create(:project, name: 'Foo_new', description: 'second', created_at: Time.now - 3.hours)
    create(:project, name: 'Foobar_new', description: 'first')
    login_as nil
    get :index, q: 'foo', sort: 'new'
    must_respond_with :ok
    response.body.must_match(/first.*second/m)
  end

  it 'index should handle query param sorting by "activity_level"' do
    create(:project, name: 'Foo_activity_level', description: 'second', activity_level_index: 0)
    create(:project, name: 'Foobar_activity_level', description: 'first', activity_level_index: 20)
    login_as nil
    get :index, q: 'foo', sort: 'activity_level'
    must_respond_with :ok
    response.body.must_match(/first.*second/m)
  end

  it 'index should handle query param sorting by "users"' do
    create(:project, name: 'Foo_users', description: 'second', user_count: 1)
    create(:project, name: 'Foobar_users', description: 'first', user_count: 20)
    login_as nil
    get :index, q: 'foo', sort: 'users'
    must_respond_with :ok
    response.body.must_match(/first.*second/m)
  end

  it 'index should handle query param sorting by "rating"' do
    create(:project, name: 'Foo_rating', description: 'second', rating_average: 2)
    create(:project, name: 'Foobar_rating', description: 'first', rating_average: 4)
    login_as nil
    get :index, q: 'foo', sort: 'rating'
    must_respond_with :ok
    response.body.must_match(/first.*second/m)
  end

  it 'index should handle query param sorting by "active_committers"' do
    create(:project, name: 'Foo_active_committers', description: 'second', active_committers: 23)
    create(:project, name: 'Foobar_active_committers', description: 'first', active_committers: 42)
    login_as nil
    get :index, q: 'foo', sort: 'active_committers'
    must_respond_with :ok
    response.body.must_match(/first.*second/m)
  end

  it 'index should handle query param with atom format' do
    create(:project, name: 'Foo_atom', description: 'second', rating_average: 2)
    create(:project, name: 'Foobar_atom', description: 'first', rating_average: 4)
    login_as nil
    get :index, q: 'foo', sort: 'rating', format: 'atom'
    must_respond_with :ok
    nodes = Nokogiri::XML(response.body).css('entry')
    nodes.length.must_equal 2
    nodes[0].css('title').children.to_s.must_equal 'Foobar_atom'
    nodes[1].css('title').children.to_s.must_equal 'Foo_atom'
  end
end
