# frozen_string_literal: true

require 'test_helper'

class StackIgnoresControllerTest < ActionController::TestCase
  # create action
  it 'create should require a current user' do
    stack = create(:stack)
    project = create(:project)
    login_as nil
    post :create, stack_id: stack, stack_ignore: { project_id: project }
    must_respond_with :redirect
    must_redirect_to new_session_path
    StackIgnore.where(stack_id: stack.id, project_id: project.id).count.must_equal 0
  end

  it 'create should require the current user matches the stack owner' do
    stack = create(:stack)
    project = create(:project)
    login_as create(:account)
    post :create, stack_id: stack, stack_ignore: { project_id: project }
    must_respond_with :not_found
    StackIgnore.where(stack_id: stack.id, project_id: project.id).count.must_equal 0
  end

  it 'create should persist a stack ignore into the db' do
    stack = create(:stack)
    project = create(:project)
    login_as stack.account
    post :create, stack_id: stack, stack_ignore: { project_id: project }
    must_respond_with :ok
    StackIgnore.where(stack_id: stack.id, project_id: project.id).count.must_equal 1
  end

  it 'create should gracefully handle garbage project_id' do
    stack = create(:stack)
    login_as stack.account
    post :create, stack_id: stack, stack_ignore: { project_id: 'i_am_a_banana' }
    must_respond_with :not_found
    StackIgnore.where(stack_id: stack.id).count.must_equal 0
  end

  it 'create should gracefully handle garbage stack_id' do
    project = create(:project)
    login_as create(:account)
    post :create, stack_id: 'i_am_a_banana', stack_ignore: { project_id: project }
    must_respond_with :not_found
    StackIgnore.where(project_id: project.id).count.must_equal 0
  end

  # delete_all action
  it 'delete_all should require a current user' do
    stack_ignore = create(:stack_ignore)
    login_as nil
    post :delete_all, stack_id: stack_ignore.stack
    must_respond_with :redirect
    must_redirect_to new_session_path
    StackIgnore.where(stack_id: stack_ignore.stack.id).count.must_equal 1
  end

  it 'delete_all should require the current user matches the stack owner' do
    stack_ignore = create(:stack_ignore)
    login_as create(:account)
    post :delete_all, stack_id: stack_ignore.stack
    must_respond_with :not_found
    StackIgnore.where(stack_id: stack_ignore.stack.id).count.must_equal 1
  end

  it 'delete_all should clear all stack ignores for that stack from the db' do
    stack = create(:stack)
    create(:stack_ignore, stack: stack)
    create(:stack_ignore, stack: stack)
    stack_ignore_for_other_stack = create(:stack_ignore)
    login_as stack.account
    post :delete_all, stack_id: stack
    must_respond_with :ok
    StackIgnore.where(stack_id: stack.id).count.must_equal 0
    StackIgnore.where(stack_id: stack_ignore_for_other_stack.stack.id).count.must_equal 1
  end
end
