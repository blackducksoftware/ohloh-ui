require 'test_helper'

class StackEntriesControllerTest < ActionController::TestCase
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
      xml_http_request :post, 'create', stack_id: stack, project_id: project
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

  # Wny does this test not work. I pass in the correct parameters. It should decrease by one.
  it 'destroy should mark the stack entry as deleted with xhr request' do
    stack = create(:stack)
    project = create(:project)
    stack_entry = create(:stack_entry, project: project, stack: stack)
    login_as stack.account
    xml_http_request :delete, 'destroy', id: stack_entry, stack_id: stack
    must_respond_with :ok
    stack_entry.reload.deleted_at.wont_equal nil
  end
end
