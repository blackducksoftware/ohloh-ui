require 'test_helper'

describe 'StackEntriesController' do
  # show
  it 'show should return good json for a stack entry' do
    login_as(create(:account))
    stack_entry = create(:stack_entry)
    get :show, format: :json, id: stack_entry, stack_id: stack_entry.stack
    must_respond_with :ok
    result = JSON.parse(@response.body)
    result['id'].must_equal stack_entry.id
  end

  # create action
  it 'create should require a current user' do
    stack = create(:stack)
    project = create(:project)
    login_as nil
    post :create, stack_id: stack, stack_entry: { project_id: project }
    must_respond_with :redirect
    must_redirect_to new_session_path
    StackEntry.where(stack_id: stack.id, project_id: project.id).count.must_equal 0
  end

  it 'create should require the current user matches the stack owner' do
    stack = create(:stack)
    project = create(:project)
    login_as create(:account)
    post :create, stack_id: stack, stack_entry: { project_id: project }
    must_respond_with :not_found
    StackEntry.where(stack_id: stack.id, project_id: project.id).count.must_equal 0
  end

  it 'create should persist a stack entry into the db' do
    stack = create(:stack)
    project = create(:project)
    login_as stack.account
    post :create, stack_id: stack, stack_entry: { project_id: project }
    result = JSON.parse(@response.body)
    must_respond_with :ok
    result['newly_added'].must_equal true
    StackEntry.where(stack_id: stack.id, project_id: project.id).count.must_equal 1
  end

  it 'create should persist a stack entry into the db if the request was xhr' do
    stack = create(:stack)
    project = create(:project)
    login_as stack.account
    assert_difference 'StackEntry.count', 1 do
      xml_http_request :post, 'create', stack_id: stack, stack_entry: { project_id: project.vanity_url }
    end
  end

  it 'create should gracefully handle garbage project_id' do
    stack = create(:stack)
    login_as stack.account
    post :create, stack_id: stack, stack_entry: { project_id: 'i_am_a_banana' }
    must_respond_with :not_found
    StackEntry.where(stack_id: stack.id).count.must_equal 0
  end

  it 'create should gracefully handle garbage stack_id' do
    project = create(:project)
    login_as create(:account)
    post :create, stack_id: 'i_am_a_banana', stack_entry: { project_id: project }
    must_respond_with :not_found
    StackEntry.where(project_id: project.id).count.must_equal 0
  end

  it 'create should gracefully handle save errors' do
    stack = create(:stack)
    project = create(:project)
    login_as stack.account
    StackEntry.stubs(:create!).raises(ActiveRecord::Rollback)
    post :create, stack_id: stack, stack_entry: { project_id: project }
    must_respond_with :unprocessable_entity
  end

  it 'create should gracefully handle the POST coming in twice (i.e. - project alreay in stack)' do
    stack = create(:stack)
    project = create(:project)
    create(:stack_entry, stack: stack, project: project)
    login_as stack.account
    post :create, stack_id: stack, stack_entry: { project_id: project }
    must_respond_with :ok
    StackEntry.where(stack_id: stack.id, project_id: project.id).count.must_equal 1
  end

  # update
  it 'update should allow updating of a stack entrys note' do
    stack_entry = create(:stack_entry)
    login_as stack_entry.stack.account
    put :update, id: stack_entry, stack_id: stack_entry.stack, stack_entry: { note: 'Changed!' }
    must_respond_with :ok
    stack_entry.reload.note.must_equal 'Changed!'
  end

  it 'update should gracefully handle update failures' do
    StackEntry.any_instance.stubs(:update).returns false
    stack_entry = create(:stack_entry)
    login_as stack_entry.stack.account
    put :update, id: stack_entry, stack_id: stack_entry.stack, stack_entry: { note: 'Changed!' }
    must_respond_with :unprocessable_entity
  end

  # destroy action
  it 'destroy should require a current user' do
    project = create(:project)
    stack_entry = create(:stack_entry, project: project)
    login_as nil
    post :destroy, id: stack_entry, stack_id: stack_entry.stack, stack_entry: { project_id: project }
    must_respond_with :redirect
    must_redirect_to new_session_path
    assert_nil stack_entry.reload.deleted_at
  end

  it 'destroy should require the current user matches the stack owner' do
    project = create(:project)
    stack_entry = create(:stack_entry, project: project)
    login_as create(:account)
    post :destroy, id: stack_entry, stack_id: stack_entry.stack, stack_entry: { project_id: project }
    must_respond_with :not_found
    assert_nil stack_entry.reload.deleted_at
  end

  it 'destroy should mark the stack entry as deleted' do
    project = create(:project)
    stack_entry = create(:stack_entry, project: project)
    login_as stack_entry.stack.account
    post :destroy, id: stack_entry, stack_id: stack_entry.stack, stack_entry: { project_id: project }
    must_respond_with :ok
    stack_entry.reload.deleted_at.wont_equal nil
  end

  it 'destroy should mark the stack entry as deleted with xhr request' do
    stack = create(:stack)
    project = create(:project)
    stack_entry = create(:stack_entry, project: project, stack: stack)
    login_as stack.account
    xml_http_request :delete, 'destroy', id: stack_entry, stack_id: stack
    must_respond_with :ok
    stack.stack_entries.count.must_equal 0
  end

  describe 'new' do
    let(:project) { create(:project) }
    before { login_as(create(:account)) }

    it 'wont work without a valid project param' do
      get :new, project_id: 'junk'

      must_respond_with :not_found
    end

    it 'must handle ajax request' do
      xhr :get, :new, project_id: project.id

      must_render_template 'new'
    end
  end
end
