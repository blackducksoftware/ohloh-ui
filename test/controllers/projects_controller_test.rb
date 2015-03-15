require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  # index
  it 'index should handle query param for unlogged users' do
    project1 = create(:project, name: 'Foo', description: Faker::Lorem.sentence(90))
    project2 = create(:project, name: 'Foobar', description: Faker::Lorem.sentence(90))
    project3 = create(:project, name: 'Goobaz', description: Faker::Lorem.sentence(90))
    login_as nil
    get :index, query: 'foo'
    must_respond_with :ok
    must_select "div.well#project_#{project1.id}", true
    must_select "div.well#project_#{project2.id}", true
    must_select "div.well#project_#{project3.id}", false
  end

  it 'index should handle query param that matches no project' do
    get :index, query: 'qwertyuioplkjhgfdsazxcvbnm'
    must_respond_with :ok
    must_select 'div.advanced_search_tips', true
  end

  it 'index should handle query param sorting by "new"' do
    create(:project, name: 'Foo_new', description: 'second', created_at: Time.now - 3.hours)
    create(:project, name: 'Foobar_new', description: 'first')
    login_as nil
    get :index, query: 'foo', sort: 'new'
    must_respond_with :ok
    response.body.must_match(/first.*second/m)
  end

  it 'index should handle query param sorting by "activity_level"' do
    create(:project, name: 'Foo_activity_level', description: 'second', activity_level_index: 0)
    create(:project, name: 'Foobar_activity_level', description: 'first', activity_level_index: 20)
    login_as nil
    get :index, query: 'foo', sort: 'activity_level'
    must_respond_with :ok
    response.body.must_match(/first.*second/m)
  end

  it 'index should handle query param sorting by "users"' do
    create(:project, name: 'Foo_users', description: 'second', user_count: 1)
    create(:project, name: 'Foobar_users', description: 'first', user_count: 20)
    login_as nil
    get :index, query: 'foo', sort: 'users'
    must_respond_with :ok
    response.body.must_match(/first.*second/m)
  end

  it 'index should handle query param sorting by "rating"' do
    create(:project, name: 'Foo_rating', description: 'second', rating_average: 2)
    create(:project, name: 'Foobar_rating', description: 'first', rating_average: 4)
    login_as nil
    get :index, query: 'foo', sort: 'rating'
    must_respond_with :ok
    response.body.must_match(/first.*second/m)
  end

  it 'index should handle query param sorting by "active_committers"' do
    create(:project, name: 'Foo_active_committers', description: 'second', active_committers: 23)
    create(:project, name: 'Foobar_active_committers', description: 'first', active_committers: 42)
    login_as nil
    get :index, query: 'foo', sort: 'active_committers'
    must_respond_with :ok
    response.body.must_match(/first.*second/m)
  end

  it 'index should handle query param with atom format' do
    create(:project, name: 'Foo_atom', description: 'second', rating_average: 2)
    create(:project, name: 'Foobar_atom', description: 'first', rating_average: 4)
    login_as nil
    get :index, query: 'foo', sort: 'rating', format: 'atom'
    must_respond_with :ok
    nodes = Nokogiri::XML(response.body).css('entry')
    nodes.length.must_equal 2
    nodes[0].css('title').children.to_s.must_equal 'Foobar_atom'
    nodes[1].css('title').children.to_s.must_equal 'Foo_atom'
  end

  it 'index should not respond to xml format without an api_key' do
    login_as nil
    get :index, query: 'foo', sort: 'rating', format: 'xml'
    must_respond_with :unauthorized
  end

  it 'index should not respond to xml format with a banned api_key' do
    login_as nil
    key = create(:api_key, status: ApiKey::STATUS_DISABLED).key
    get :index, query: 'foo', sort: 'rating', api_key: key, format: :xml
    must_respond_with :unauthorized
  end

  it 'index should not respond to xml format with an over-limit api_key' do
    login_as nil
    get :index, query: 'foo', sort: 'rating', api_key: create(:api_key, daily_count: 999_999).key, format: :xml
    must_respond_with :unauthorized
  end

  it 'index should respond to xml format' do
    create(:project, name: 'Foo_xml', description: 'second', rating_average: 2)
    create(:project, name: 'Foobar_xml', description: 'first', rating_average: 4)
    login_as nil
    get :index, query: 'foo', sort: 'rating', api_key: create(:api_key).key, format: :xml
    must_respond_with :ok
    nodes = Nokogiri::XML(response.body).css('project')
    nodes.length.must_equal 2
    nodes[0].css('name').children.to_s.must_equal 'Foobar_xml'
    nodes[1].css('name').children.to_s.must_equal 'Foo_xml'
  end

  it 'index should handle account sorting by "new"' do
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

  # new
  it 'new should require a current user' do
    login_as nil
    get :new
    must_respond_with :unauthorized
  end

  it 'new should render for logged users' do
    login_as create(:account)
    get :new
    must_respond_with :ok
  end

  # edit
  it 'edit should disable save button for unlogged users' do
    login_as nil
    get :edit, id: create(:project).id
    must_respond_with :ok
    must_select 'input.save', 0
    must_select '.disabled.save', 1
  end

  it 'edit should enable save button for managers' do
    project = create(:project)
    manager = create(:account)
    Manage.create(target: project, account: manager)
    login_as manager
    get :edit, id: project.id
    must_respond_with :ok
    must_select 'input.save', 1
    must_select '.disabled.save', 0
  end

  it 'edit should enable save button for admins' do
    login_as create(:admin)
    get :edit, id: create(:project).id
    must_respond_with :ok
    must_select 'input.save', 1
    must_select '.disabled.save', 0
  end

  # update
  it 'update should refuse unauthorized attempts' do
    project = create(:project)
    login_as nil
    put :update, id: project.id, project: { name: 'KoolOSSProject' }
    must_respond_with :unauthorized
    project.reload.name.wont_equal 'KoolOSSProject'
  end

  it 'update should persist changes' do
    project = create(:project)
    login_as create(:admin)
    put :update, id: project.id, project: { name: 'KoolOSSProject' }
    must_respond_with 302
    project.reload.name.must_equal 'KoolOSSProject'
  end

  it 'update should handle invalid params and render the edit action' do
    project = create(:project, name: 'KoolOSSProject123')
    login_as create(:admin)
    put :update, id: project.id, project: { name: '' }
    must_respond_with :unprocessable_entity
    project.reload.name.must_equal 'KoolOSSProject123'
    must_select 'input.save', 1
    must_select 'p.error[rel="name"]', 1
  end

  # estimated_cost
  it 'estimated_cost should display for analyzed projects' do
    login_as nil
    get :estimated_cost, id: create(:project).id
    must_respond_with :success
    response.body.must_match I18n.t('projects.estimated_cost.project_cost_calculator')
    must_select '.no_analysis_message', 0
  end

  it 'estimated_cost should display for unanalyzed projects' do
    project = create(:project)
    project.update_attributes(best_analysis_id: nil)
    login_as nil
    get :estimated_cost, id: project.id
    must_respond_with :success
    response.body.wont_match I18n.t('projects.estimated_cost.project_cost_calculator')
    must_select '.no_analysis_message', 1
  end

  it 'should show the project users page' do
    project = create(:project, logo: nil)
    account = create(:account)
    create(:stack_entry, stack: create(:stack, account: account), project: project)
    create(:stack_entry, stack: create(:stack, account: account), project: project)
    get :users, id: project.id
    must_respond_with :success
    must_select '.advanced_search_tips', 0
    assigns(:accounts).count.must_equal 2
  end

  it 'should search for a valid account' do
    project = create(:project, logo: nil)
    account1 = create(:account)
    account2 = create(:account)
    create(:stack_entry, stack: create(:stack, account: account1), project: project)
    create(:stack_entry, stack: create(:stack, account: account2), project: project)

    get :users, id: project.id, query: account1.name
    must_respond_with :success
    must_select '.advanced_search_tips', 0
    assigns(:accounts).count.must_equal 1
  end

  it 'should not list a invalid search term' do
    project = create(:project, logo: nil)
    get :users, id: project.id, query: 'unknown_text_to_seach'
    must_respond_with :success
    must_select '.advanced_search_tips', 1
    assigns(:accounts).count.must_equal 0
  end
end
