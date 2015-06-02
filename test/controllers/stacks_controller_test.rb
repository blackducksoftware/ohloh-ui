require 'test_helper'

class StacksControllerTest < ActionController::TestCase
  # index action
  it 'index should not require a current user' do
    stack = create(:stack)
    login_as nil
    get :index, account_id: stack.account
    must_respond_with :ok
  end

  it 'index should display for users with no stacks' do
    get :index, account_id: create(:account)
    must_respond_with :ok
  end

  it 'index should gracefully handle non-existant users' do
    get :index, account_id: 'i_am_one_big_teapot'
    must_respond_with :not_found
  end

  it 'index should gracefully handle disabled users' do
    get :index, account_id: create(:disabled_account)
    must_respond_with :not_found
  end

  it 'index should gracefully handle spammers' do
    get :index, account_id: create(:spammer)
    must_respond_with :not_found
  end

  it 'index should gracefully handle unactivated users' do
    get :index, account_id: create(:unactivated)
    must_respond_with :not_found
  end

  it 'index should display when the stack has no projects associated with it' do
    stack = create(:stack, title: 'i_am_there')
    login_as stack.account
    get :index, account_id: stack.account
    must_respond_with :ok
    response.body.must_match stack.title
  end

  it 'index should display when the stack has projects associated with it' do
    stack = create(:stack, title: 'i_am_there')
    create(:stack_entry, stack: stack)
    login_as stack.account
    get :index, account_id: stack.account
    must_respond_with :ok
    response.body.must_match stack.title
  end

  it 'index should display when the stack has projects with no logos associated with it' do
    stack = create(:stack, title: 'i_am_there')
    create(:stack_entry, stack: stack, project: create(:project, logo: nil))
    login_as stack.account
    get :index, account_id: stack.account
    must_respond_with :ok
    response.body.must_match stack.title
  end

  it 'index should not display deleted stacks' do
    stack = create(:stack, title: 'i_am_deleted')
    stack.destroy
    login_as stack.account
    get :index, account_id: stack.account
    must_respond_with :ok
    response.body.wont_match stack.title
  end

  # show action
  it 'show should not require a current user' do
    stack = create(:stack)
    login_as nil
    get :show, id: stack
    must_respond_with :ok
  end

  it 'show should return 404 for disabled users stacks' do
    stack = create(:stack, account: create(:disabled_account))
    login_as nil
    get :show, id: stack
    must_respond_with :not_found
  end

  it 'show should offer edit links to stack owner' do
    stack = create(:stack)
    login_as stack.account
    get :show, id: stack
    must_respond_with :ok
    response.body.must_match I18n.t('stacks.edit_in_place')
  end

  it 'show should not offer edit links to unlogged user' do
    stack = create(:stack)
    login_as nil
    get :show, id: stack
    must_respond_with :ok
    response.body.wont_match I18n.t('stacks.edit_in_place')
  end

  it 'show should not offer edit links to other users' do
    stack = create(:stack)
    login_as create(:account)
    get :show, id: stack
    must_respond_with :ok
    response.body.wont_match I18n.t('stacks.edit_in_place')
  end

  it 'show should star ratings for projects' do
    stack = create(:stack)
    create(:stack_entry, stack: stack, project: create(:project, rating_average: 0))
    create(:stack_entry, stack: stack, project: create(:project, rating_average: 2.5))
    create(:stack_entry, stack: stack, project: create(:project, rating_average: 5))
    login_as stack.account
    get :show, id: stack
    must_respond_with :ok
    response.body.must_match 'rating_stars'
  end

  it 'show should support format: json' do
    stack = create(:stack)
    login_as nil
    get :show, id: stack, format: :json
    must_respond_with :ok
    resp = JSON.parse(response.body)
    resp['title'].must_equal stack.title
    resp['description'].must_equal stack.description
  end

  # create action
  it 'create should require a current user' do
    login_as nil
    post :create
    must_respond_with :unauthorized
  end

  it 'create should require a current user' do
    account = create(:account)
    login_as account
    post :create
    must_respond_with 302
    Stack.where(account_id: account.id).count.must_equal 1
  end

  it 'create should gracefully handle save errors' do
    login_as create(:account)
    Stack.any_instance.expects(:save).returns false
    post :create
    must_respond_with 302
  end

  it 'create should hande an ajax request for I Use This' do
    account = create(:account)
    project = create(:project)
    login_as account
    xml_http_request :post, 'create'
    must_render_template 'stacks/i_use_this.js.erb'
    assert_difference 'Stack.count', 1 do
      xml_http_request :post, 'create'
    end
    assert_difference 'StackEntry.count', 1 do
      xml_http_request :post, 'create'
    end
  end

  # update action
  it 'update should require a current user' do
    login_as nil
    put :update, id: create(:stack), stack: { title: 'Best Stack EVAR!' }
    must_respond_with :unauthorized
  end

  it 'update should not work for wrong user' do
    stack = create(:stack, title: 'original')
    login_as create(:account)
    put :update, id: stack, stack: { title: 'changed' }
    must_respond_with :not_found
    stack.reload.title.must_equal 'original'
  end

  it 'update should work for owner changing title' do
    stack = create(:stack, title: 'original')
    login_as stack.account
    put :update, id: stack, stack: { title: 'changed' }
    must_respond_with :ok
    stack.reload.title.must_equal 'changed'
  end

  it 'update should work for owner changing description' do
    stack = create(:stack, description: 'original')
    login_as stack.account
    put :update, id: stack, stack: { description: 'changed' }
    must_respond_with :ok
    stack.reload.description.must_equal 'changed'
  end

  it 'update should gracefully handle errors' do
    stack = create(:stack, description: 'original')
    login_as stack.account
    Stack.any_instance.expects(:update_attributes).returns false
    put :update, id: stack, stack: { description: 'changed' }
    must_respond_with :unprocessable_entity
  end

  # destroy action
  it 'destroy should require a current user' do
    login_as nil
    delete :destroy, id: create(:stack)
    must_respond_with :unauthorized
  end

  it 'destroy should not destroy stack owned by someone else' do
    stack = create(:stack)
    login_as create(:account)
    delete :destroy, id: stack
    must_respond_with :not_found
    stack.reload.deleted_at.must_equal nil
  end

  it 'destroy should destroy stack' do
    stack = create(:stack)
    login_as stack.account
    delete :destroy, id: stack
    must_respond_with 200
    Stack.where(id: stack.id).count.must_equal 0
  end

  it 'destroy should gracefully handle errors' do
    stack = create(:stack)
    login_as stack.account
    Stack.any_instance.expects(:destroy).returns false
    delete :destroy, id: stack
    must_respond_with :unprocessable_entity
  end

  # similar action
  it 'similar should not require a current user' do
    login_as nil
    get :similar, id: create(:stack)
    must_respond_with :ok
  end

  it 'similar should work with a current user' do
    stack1 = create(:stack)
    stack2 = create(:stack)
    stack3 = create(:stack)

    proj1 = create(:project)
    proj2 = create(:project)
    proj3 = create(:project)

    stack1.projects = [proj1, proj2, proj3]
    stack2.projects = [proj2, proj3]
    stack3.projects = [proj1, proj3]

    login_as create(:account)
    get :similar, id: stack3
    must_respond_with :ok
  end

  # builder action
  it 'builder should require a current user' do
    stack = create(:stack)
    login_as nil
    get :builder, id: stack, format: :json
    must_respond_with :unauthorized
  end

  it 'builder should require real owner' do
    login_as create(:account)
    get :builder, id: create(:stack), format: :json
    must_respond_with :not_found
  end

  it 'builder should support format: json' do
    project = create(:project)
    stack = create(:stack)
    login_as stack.account
    Stack.any_instance.expects(:suggest_projects).returns [project]
    get :builder, id: stack, format: :json
    must_respond_with :ok
    resp = JSON.parse(response.body)
    resp['recommendations'].must_match project.name
  end

  it 'builder should support the ignore option' do
    project1 = create(:project)
    project2 = create(:project)
    stack = create(:stack)
    login_as stack.account
    get :builder, id: stack, ignore: "#{project1.url_name},#{project2.url_name}", format: :json
    must_respond_with :ok
    StackIgnore.where(stack_id: stack.id, project_id: project1.id).count.must_equal 1
    StackIgnore.where(stack_id: stack.id, project_id: project2.id).count.must_equal 1
  end

  # near
  it 'near should display for unlogged in users' do
    login_as nil
    project = create(:project)
    account = create(:account, latitude: 30.26, longitude: -97.74)
    stack = create(:stack, account: account)
    create(:stack_entry, project: project, stack: stack)
    get :near, project_id: project.to_param, lat: 25, lng: 12, zoom: 2
    must_respond_with :success
    resp = JSON.parse(response.body)
    resp['accounts'].length.must_equal 1
    resp['accounts'][0]['id'].must_equal account.id
    resp['accounts'][0]['latitude'].must_equal account.latitude.to_s
    resp['accounts'][0]['longitude'].must_equal account.longitude.to_s
  end

  it 'near should support zoomed in values' do
    login_as nil
    project = create(:project)
    account = create(:account, latitude: 30.26, longitude: -97.74)
    stack = create(:stack, account: account)
    create(:stack_entry, project: project, stack: stack)
    get :near, project_id: project.to_param, lat: 25, lng: 12, zoom: 4
    must_respond_with :success
    resp = JSON.parse(response.body)
    resp['accounts'].length.must_equal 1
    resp['accounts'][0]['id'].must_equal account.id
    resp['accounts'][0]['latitude'].must_equal account.latitude.to_s
    resp['accounts'][0]['longitude'].must_equal account.longitude.to_s
  end
end
