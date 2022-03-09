# frozen_string_literal: true

require 'test_helper'

class StackIgnoresControllerTest < ActionController::TestCase
  # create action
  it 'create should require a current user' do
    stack = create(:stack)
    project = create(:project)
    login_as nil
    post :create, params: { stack_id: stack, stack_ignore: { project_id: project } }
    assert_response :redirect
    assert_redirected_to new_session_path
    _(StackIgnore.where(stack_id: stack.id, project_id: project.id).count).must_equal 0
  end

  it 'create should require the current user matches the stack owner' do
    stack = create(:stack)
    project = create(:project)
    login_as create(:account)
    post :create, params: { stack_id: stack, stack_ignore: { project_id: project } }
    assert_response :not_found
    _(StackIgnore.where(stack_id: stack.id, project_id: project.id).count).must_equal 0
  end

  it 'create should persist a stack ignore into the db' do
    stack = create(:stack)
    project = create(:project)
    login_as stack.account
    post :create, params: { stack_id: stack, stack_ignore: { project_id: project } }
    assert_response :ok
    _(StackIgnore.where(stack_id: stack.id, project_id: project.id).count).must_equal 1
  end

  it 'create should gracefully handle garbage project_id' do
    stack = create(:stack)
    login_as stack.account
    post :create, params: { stack_id: stack, stack_ignore: { project_id: 'i_am_a_banana' } }
    assert_response :not_found
    _(StackIgnore.where(stack_id: stack.id).count).must_equal 0
  end

  it 'create should gracefully handle garbage stack_id' do
    project = create(:project)
    login_as create(:account)
    post :create, params: { stack_id: 'i_am_a_banana', stack_ignore: { project_id: project } }
    assert_response :not_found
    _(StackIgnore.where(project_id: project.id).count).must_equal 0
  end

  # delete_all action
  it 'delete_all should require a current user' do
    stack_ignore = create(:stack_ignore)
    login_as nil
    post :delete_all, params: { stack_id: stack_ignore.stack }
    assert_response :redirect
    assert_redirected_to new_session_path
    _(StackIgnore.where(stack_id: stack_ignore.stack.id).count).must_equal 1
  end

  it 'delete_all should require the current user matches the stack owner' do
    stack_ignore = create(:stack_ignore)
    login_as create(:account)
    post :delete_all, params: { stack_id: stack_ignore.stack }
    assert_response :not_found
    _(StackIgnore.where(stack_id: stack_ignore.stack.id).count).must_equal 1
  end

  it 'delete_all should clear all stack ignores for that stack from the db' do
    stack = create(:stack)
    create(:stack_ignore, stack: stack)
    create(:stack_ignore, stack: stack)
    stack_ignore_for_other_stack = create(:stack_ignore)
    login_as stack.account
    post :delete_all, params: { stack_id: stack }
    assert_response :ok
    _(StackIgnore.where(stack_id: stack.id).count).must_equal 0
    _(StackIgnore.where(stack_id: stack_ignore_for_other_stack.stack.id).count).must_equal 1
  end
end
