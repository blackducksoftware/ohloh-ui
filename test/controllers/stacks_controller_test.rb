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
    response.body.must_match(stack.title)
  end

  it 'index should display when the stack has projects associated with it' do
    stack = create(:stack, title: 'i_am_there')
    create(:stack_entry, stack: stack)
    login_as stack.account
    get :index, account_id: stack.account
    must_respond_with :ok
    response.body.must_match(stack.title)
  end

  it 'index should display when the stack has projects with no logos associated with it' do
    stack = create(:stack, title: 'i_am_there')
    create(:stack_entry, stack: stack, project: create(:project, logo: nil))
    login_as stack.account
    get :index, account_id: stack.account
    must_respond_with :ok
    response.body.must_match(stack.title)
  end

  it 'index should not display deleted stacks' do
    stack = create(:stack, title: 'i_am_deleted')
    stack.destroy
    login_as stack.account
    get :index, account_id: stack.account
    must_respond_with :ok
    response.body.wont_match(stack.title)
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
    Stack.any_instance.stubs(:save).returns false
    post :create
    must_respond_with 302
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
    must_respond_with 302
    Stack.where(id: stack.id).count.must_equal 0
  end
end
