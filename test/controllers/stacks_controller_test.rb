require 'test_helper'

describe 'StacksControllerTest' do
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

  it 'must redirect for disabled account' do
    account = create(:account)
    login_as account
    account.access.spam!

    get :index, account_id: account

    must_redirect_to disabled_account_url(account)
  end

  it 'index must allow access to unactivated users' do
    get :index, account_id: create(:unactivated)
    must_respond_with :ok
  end

  it 'index should paginate by 10 entries' do
    account = create(:account, :with_stacks, number_of_stacks: 12)
    login_as account
    get :index, account_id: account
    stacks = assigns(:stacks)
    stacks.size.must_equal 10
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

  it 'show: must redirect to disabled page for disabled users stacks' do
    account = create(:account)
    login_as account
    account.access.spam!
    stack = create(:stack, account: account)
    get :show, id: stack
    must_redirect_to disabled_account_url(account)
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

  it 'show should paginate by 10 entries' do
    stack = create(:stack)
    create_list(:stack_entry, 12, stack: stack)
    get :show, id: stack
    stack_entries = assigns(:stack_entries)
    stack_entries.size.must_equal 10
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

  describe 'create' do
    let(:project) { create(:project) }
    let(:account) { create(:account) }
    before { login_as(account) }

    describe 'default behaviour' do
      before do
        post :create
      end

      it 'must update stack with default data' do
        stack = assigns(:stack)

        stack.must_be :persisted?
        stack.account.must_equal account
        stack.title.must_equal 'New Stack 1'
        stack.description.must_be_nil
      end
    end

    describe 'with stack_entries_attributes' do
      let(:stack_entry_params) { { stack_entries_attributes: { '0' => { project_id: project.id } } } }

      it 'must check for a valid project_id' do
        post :create, stack: stack_entry_params

        must_respond_with :not_found
      end

      it 'must create stack entries' do
        post :create, project_id: project.id, stack: stack_entry_params

        stack = assigns(:stack)
        stack.must_be :persisted?
        stack.stack_entries.must_be :present?
      end

      it 'must update stack with default data' do
        post :create, project_id: project.id, stack: stack_entry_params
        stack = assigns(:stack)

        stack.must_be :persisted?
        stack.account.must_equal account
        stack.title.must_equal 'New Stack 1'
        stack.description.must_equal "The Projects used for #{stack.title}"
      end
    end
  end

  # update action
  it 'update should require a current user' do
    login_as nil
    put :update, id: create(:stack), stack: { title: 'Best Stack EVAR!' }
    must_respond_with :redirect
    must_redirect_to new_session_path
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
    Stack.any_instance.expects(:update).returns false
    put :update, id: stack, stack: { description: 'changed' }
    must_respond_with :unprocessable_entity
  end

  # destroy action
  it 'destroy should require a current user' do
    login_as nil
    delete :destroy, id: create(:stack)
    must_respond_with :redirect
    must_redirect_to new_session_path
  end

  it 'destroy should not destroy stack owned by someone else' do
    stack = create(:stack)
    login_as create(:account)
    delete :destroy, id: stack
    must_respond_with :not_found
    assert_nil stack.reload.deleted_at
  end

  it 'destroy should destroy stack' do
    stack = create(:stack)
    login_as stack.account
    delete :destroy, id: stack
    must_respond_with :redirect
    must_redirect_to account_stacks_path(stack.account)
    Stack.where(id: stack.id).count.must_equal 0
  end

  it 'destroy should gracefully handle errors' do
    stack = create(:stack)
    login_as stack.account
    Stack.any_instance.expects(:destroy).returns false
    delete :destroy, id: stack
    must_respond_with :redirect
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
    get :builder, id: stack, ignore: "#{project1.vanity_url},#{project2.vanity_url}", format: :json
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

  describe 'reset' do
    it 'should destroy all stack entries and ignores' do
      stack_entry = create(:stack_entry)
      stack = stack_entry.stack
      create(:stack_ignore, stack: stack)
      login_as stack.account
      stack.stack_entries.count.must_equal 1
      stack.stack_ignores.count.must_equal 1
      get :reset, id: stack.id
      must_respond_with :redirect
      must_redirect_to stack_path(stack)
      stack.stack_entries.count.must_equal 0
      stack.stack_ignores.count.must_equal 0
    end

    it 'should create sample projects based on init' do
      stack = create(:stack, project: create(:project, id: 28))
      login_as stack.account
      get :reset, id: stack.id, init: 'lamp'
      must_respond_with :redirect
      must_redirect_to stack_path(stack)
      stack.reload.stack_entries.count.must_equal 1
      stack.stack_ignores.count.must_equal 0
    end
  end

  describe 'similar_stacks' do
    it 'must render the partial' do
      get :similar_stacks, id: create(:stack).id
      must_respond_with :ok
      must_render_template 'stacks/_similar_stacks'
    end
  end

  describe 'project_stacks' do
    it 'should succeed with a valid api key' do
      api_key = create(:api_key)
      get :project_stacks, id: create(:project), format: :xml, api_key: api_key.oauth_application.uid
      must_respond_with :ok
    end

    it 'must render projects/deleted when project is deleted' do
      account = create(:account)
      project = create(:project)
      project.update!(deleted: true, editor_account: account)

      get :project_stacks, id: project

      must_render_template 'deleted'
    end
  end
end
