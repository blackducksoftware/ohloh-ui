require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
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

  it 'index should not respond to xml format without an api_key' do
    login_as nil
    get :index, q: 'foo', sort: 'rating', format: 'xml'
    must_respond_with :unauthorized
  end

  it 'index should not respond to xml format with a banned api_key' do
    login_as nil
    get :index, q: 'foo', sort: 'rating', api_key: create(:api_key, status: ApiKey::STATUS_DISABLED).key, format: :xml
    must_respond_with :unauthorized
  end

  it 'index should not respond to xml format with an over-limit api_key' do
    login_as nil
    get :index, q: 'foo', sort: 'rating', api_key: create(:api_key, daily_count: 999_999).key, format: :xml
    must_respond_with :unauthorized
  end

  it 'index should respond to xml format' do
    create(:project, name: 'Foo_xml', description: 'second', rating_average: 2)
    create(:project, name: 'Foobar_xml', description: 'first', rating_average: 4)
    login_as nil
    get :index, q: 'foo', sort: 'rating', api_key: create(:api_key).key, format: :xml
    must_respond_with :ok
    nodes = Nokogiri::XML(response.body).css('project')
    nodes.length.must_equal 2
    nodes[0].css('name').children.to_s.must_equal 'Foobar_xml'
    nodes[1].css('name').children.to_s.must_equal 'Foo_xml'
  end

  it 'index should account sorting by "new"' do
    project1 = create(:project, name: 'Foo_accounts_new', description: 'second', created_at: Time.now - 3.hours)
    project2 = create(:project, name: 'Foobar_accounts_new', description: 'first')
    login_as nil
    manager = create(:account)
    create(:manage, account: manager, target: project1)
    create(:manage, account: manager, target: project2)
    get :index, account_id: manager.to_param, sort: 'new'
    must_respond_with :ok
    response.body.must_match(/first.*second/m)
  end

  it 'index should handle account sorting by "users"' do
    project1 = create(:project, name: 'Foo_accounts_users', description: 'second', user_count: 1)
    project2 = create(:project, name: 'Foobar_accounts_users', description: 'first', user_count: 20)
    manager = create(:account)
    create(:manage, account: manager, target: project1)
    create(:manage, account: manager, target: project2)
    login_as nil
    get :index, account_id: manager.to_param, sort: 'users'
    must_respond_with :ok
    response.body.must_match(/first.*second/m)
  end

  it 'index should handle account sorting by "project_name"' do
    project1 = create(:project, name: 'ZZZ_second_project_name')
    project2 = create(:project, name: 'AAA_first_project_name')
    manager = create(:account)
    create(:manage, account: manager, target: project1)
    create(:manage, account: manager, target: project2)
    login_as nil
    get :index, account_id: manager.to_param, sort: 'project_name'
    must_respond_with :ok
    response.body.must_match(/first.*second/m)
  end

  # show
  it 'show should render for unlogged users' do
    project = create(:project)
    login_as nil
    get :show, id: project.to_param
    must_respond_with :ok
  end

  it 'show should render for projects that have been analyzed' do
    project = create(:project)
    af_1 = create(:activity_fact, analysis: project.best_analysis, code_added: 8_000, comments_added: 8_000)
    create(:factoid, analysis: project.best_analysis, language: af_1.language)
    af_2 = create(:activity_fact, analysis: project.best_analysis)
    create(:factoid, analysis: project.best_analysis, language: af_2.language)
    af_3 = create(:activity_fact, analysis: project.best_analysis)
    create(:factoid, analysis: project.best_analysis, language: af_3.language)
    af_4 = create(:activity_fact, analysis: project.best_analysis)
    create(:factoid, analysis: project.best_analysis, language: af_4.language)
    ats = project.best_analysis.all_time_summary
    ats.update_attributes(recent_contributors: [create(:person).id, create(:person).id])
    cf = create(:commit_flag)
    create(:analysis_sloc_set, analysis: project.best_analysis, sloc_set: cf.sloc_set)
    login_as create(:admin)
    get :show, id: project.to_param
    must_respond_with :ok
  end
end
