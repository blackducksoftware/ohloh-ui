# frozen_string_literal: true

require 'test_helper'

class StackEntriesControllerTest < ActionController::TestCase
  # show
  it 'show should return good json for a stack entry' do
    login_as(create(:account))
    stack_entry = create(:stack_entry)
    get :show, params: { format: :json, id: stack_entry, stack_id: stack_entry.stack }
    assert_response :ok
    result = JSON.parse(@response.body)
    _(result['id']).must_equal stack_entry.id
  end

  # create action
  it 'create should require a current user' do
    stack = create(:stack)
    project = create(:project)
    login_as nil
    post :create, params: { stack_id: stack, stack_entry: { project_id: project } }
    assert_response :redirect
    assert_redirected_to new_session_path
    _(StackEntry.where(stack_id: stack.id, project_id: project.id).count).must_equal 0
  end

  it 'create should require the current user matches the stack owner' do
    stack = create(:stack)
    project = create(:project)
    login_as create(:account)
    post :create, params: { stack_id: stack, stack_entry: { project_id: project } }
    assert_response :not_found
    _(StackEntry.where(stack_id: stack.id, project_id: project.id).count).must_equal 0
  end

  it 'create should persist a stack entry into the db' do
    stack = create(:stack)
    project = create(:project)
    login_as stack.account
    post :create, params: { stack_id: stack, stack_entry: { project_id: project } }
    result = JSON.parse(@response.body)
    assert_response :ok
    _(result['newly_added']).must_equal true
    _(StackEntry.where(stack_id: stack.id, project_id: project.id).count).must_equal 1
  end

  it 'create should persist a stack entry into the db if the request was xhr' do
    stack = create(:stack)
    project = create(:project)
    login_as stack.account
    assert_difference 'StackEntry.count', 1 do
      post :create, params: { stack_id: stack, stack_entry: { project_id: project.vanity_url } }, xhr: true
    end
  end

  it 'create should gracefully handle garbage project_id' do
    stack = create(:stack)
    login_as stack.account
    post :create, params: { stack_id: stack, stack_entry: { project_id: 'i_am_a_banana' } }
    assert_response :not_found
    _(StackEntry.where(stack_id: stack.id).count).must_equal 0
  end

  it 'create should gracefully handle garbage stack_id' do
    project = create(:project)
    login_as create(:account)
    post :create, params: { stack_id: 'i_am_a_banana', stack_entry: { project_id: project } }
    assert_response :not_found
    _(StackEntry.where(project_id: project.id).count).must_equal 0
  end

  it 'create should gracefully handle save errors' do
    stack = create(:stack)
    project = create(:project)
    login_as stack.account
    StackEntry.stubs(:create!).raises(ActiveRecord::Rollback)
    post :create, params: { stack_id: stack, stack_entry: { project_id: project } }
    assert_response :unprocessable_entity
  end

  it 'create should gracefully handle the POST coming in twice (i.e. - project alreay in stack)' do
    stack = create(:stack)
    project = create(:project)
    create(:stack_entry, stack: stack, project: project)
    login_as stack.account
    post :create, params: { stack_id: stack, stack_entry: { project_id: project } }
    assert_response :ok
    _(StackEntry.where(stack_id: stack.id, project_id: project.id).count).must_equal 1
  end

  # update
  it 'update should allow updating of a stack entrys note' do
    stack_entry = create(:stack_entry)
    login_as stack_entry.stack.account
    put :update, params: { id: stack_entry, stack_id: stack_entry.stack, stack_entry: { note: 'Changed!' } }
    assert_response :ok
    _(stack_entry.reload.note).must_equal 'Changed!'
  end

  it 'update should gracefully handle update failures' do
    StackEntry.any_instance.stubs(:update).returns false
    stack_entry = create(:stack_entry)
    login_as stack_entry.stack.account
    put :update, params: { id: stack_entry, stack_id: stack_entry.stack, stack_entry: { note: 'Changed!' } }
    assert_response :unprocessable_entity
  end

  # destroy action
  it 'destroy should require a current user' do
    project = create(:project)
    stack_entry = create(:stack_entry, project: project)
    login_as nil
    post :destroy, params: { id: stack_entry, stack_id: stack_entry.stack, stack_entry: { project_id: project } }
    assert_response :redirect
    assert_redirected_to new_session_path
    _(stack_entry.reload.deleted_at).must_be_nil
  end

  it 'destroy should require the current user matches the stack owner' do
    project = create(:project)
    stack_entry = create(:stack_entry, project: project)
    login_as create(:account)
    post :destroy, params: { id: stack_entry, stack_id: stack_entry.stack, stack_entry: { project_id: project } }
    assert_response :not_found
    _(stack_entry.reload.deleted_at).must_be_nil
  end

  it 'destroy should mark the stack entry as deleted' do
    project = create(:project)
    stack_entry = create(:stack_entry, project: project)
    login_as stack_entry.stack.account
    post :destroy, params: { id: stack_entry, stack_id: stack_entry.stack, stack_entry: { project_id: project } }
    assert_response :ok
    _(stack_entry.reload.deleted_at).wont_equal nil
  end

  it 'destroy should mark the stack entry as deleted with xhr request' do
    stack = create(:stack)
    project = create(:project)
    stack_entry = create(:stack_entry, project: project, stack: stack)
    login_as stack.account
    delete :destroy, params: { id: stack_entry, stack_id: stack }, xhr: true
    assert_response :ok
    _(stack.stack_entries.count).must_equal 0
  end

  describe 'new' do
    let(:project) { create(:project) }
    before { login_as(create(:account)) }

    it 'wont work without a valid project param' do
      get :new, params: { project_id: 'junk' }

      assert_response :not_found
    end

    it 'must handle ajax request' do
      get :new, params: { project_id: project.id }, xhr: true

      assert_template 'new'
    end

    it 'should not support html format' do
      stack = create(:stack)
      project = create(:project)
      login_as stack.account
      get :new, params: { project_id: project.id }
      assert_response :not_acceptable
      get :new, params: { project_id: project.id }, xhr: true
      assert_response :ok
    end
  end
end
