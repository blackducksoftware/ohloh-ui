require 'test_helper'

class StackEntriesControllerTest < ActionController::TestCase
  # show
  it 'show should return good json for a stack entry' do
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
    must_respond_with :ok
    StackEntry.where(stack_id: stack.id, project_id: project.id).count.must_equal 1
  end

  it 'create should persist a stack entry into the db if the request was xhr' do
    stack = create(:stack)
    project = create(:project)
    login_as stack.account
    assert_difference 'StackEntry.count', 1 do
      xml_http_request :post, 'create', stack_id: stack, stack_entry: { project_id: project.url_name }
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

  it 'create should gracefully save errors' do
    stack = create(:stack)
    project = create(:project)
    login_as stack.account
    StackEntry.any_instance.expects(:persisted?).twice.returns false
    post :create, stack_id: stack, stack_entry: { project_id: project }
    must_respond_with :unprocessable_entity
  end

  # update
  it 'update should allow updating of a stack entrys note' do
    stack_entry = create(:stack_entry)
    login_as stack_entry.stack.account
    put :update, id: stack_entry, stack_id: stack_entry.stack, stack_entry: { note: 'Changed!' }
    must_respond_with :ok
    stack_entry.reload.note.must_equal 'Changed!'
  end

  # destroy action
  it 'destroy should require a current user' do
    project = create(:project)
    stack_entry = create(:stack_entry, project: project)
    login_as nil
    post :destroy, id: stack_entry, stack_id: stack_entry.stack, stack_entry: { project_id: project }
    must_respond_with :redirect
    must_redirect_to new_session_path
    stack_entry.reload.deleted_at.must_equal nil
  end

  it 'destroy should require the current user matches the stack owner' do
    project = create(:project)
    stack_entry = create(:stack_entry, project: project)
    login_as create(:account)
    post :destroy, id: stack_entry, stack_id: stack_entry.stack, stack_entry: { project_id: project }
    must_respond_with :not_found
    stack_entry.reload.deleted_at.must_equal nil
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

  it 'new should return current user stacks and project' do
    stack = create(:stack)
    project = create(:project)
    stack_entry = create(:stack_entry, project: project, stack: stack)
    login_as stack.account

    get :new, project_id: project.id, ref: 'ProjectWidget%3A%3AUsers'
    must_respond_with :ok
    assigns(:project).must_equal project
    assigns(:stacks).must_equal stack.account.stacks
    stack.stack_entries.count.must_equal 1
  end
end
