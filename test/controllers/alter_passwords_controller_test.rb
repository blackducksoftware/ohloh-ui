# frozen_string_literal: true

require 'test_helper'

class AlterPasswordsControllerTest < ActionController::TestCase
  it 'must reach password edit route' do
    account = create(:account)
    login_as account
    get :edit, params: { id: account.id }
    assert_response :ok
  end

  it 'must reach password edit route with me as id' do
    account = create(:account)
    login_as account
    get :edit, params: { id: 'me' }
    assert_response :ok
  end

  it 'must fail to update if all fields are blank' do
    account = create(:account, password: 'testing')
    login_as account
    put :update, params: { id: account.id, account: { current_password: '', password: '' } }
    assert_response :unprocessable_entity
    _(flash[:error]).must_equal 'There was a problem saving!'
  end

  it 'must fail if current password is not provided' do
    account = create(:account, password: 'testing')
    login_as account
    put :update, params: { id: account.id, account: { current_password: '', password: 'newpassword' } }
    assert_response :unprocessable_entity
    _(flash[:error]).must_equal 'There was a problem saving!'
  end

  it 'must fail if current password does not match' do
    account = create(:account, password: 'testing')
    login_as account
    put :update,
        params: { id: account.id, account: { current_password: 'wrongcurrentpassword', password: 'newpassword' } }
    assert_response :unprocessable_entity
    _(flash[:error]).must_equal 'There was a problem saving!'
  end

  it 'must fail when new password is not provided' do
    account = create(:account, password: 'testing')
    login_as account
    put :update, params: { id: account.id, account: { current_password: 'testing', password: '' } }
    assert_response :unprocessable_entity
    _(flash[:error]).must_equal 'There was a problem saving!'
  end

  it 'must fail if new password is less than 5 characters' do
    account = create(:account, password: 'testing')
    login_as account
    put :update, params: { id: account.id, account: { current_password: 'testing', password: 'abc' } }
    assert_response :unprocessable_entity
    _(flash[:error]).must_equal 'There was a problem saving!'
  end

  it 'must fail if new password is more than 40 characters' do
    account = create(:account, password: 'testing')
    login_as account
    password = 'averylongpasswordthatiswaymorethanfortycharactersandshouldfailwhensubmitted'
    put :update, params: { id: account.id, account: { current_password: 'testing', password: password } }
    assert_response :unprocessable_entity
    _(flash[:error]).must_equal 'There was a problem saving!'
  end

  it 'must update password fields' do
    account = create(:account, password: 'testing')
    login_as account
    put :update, params: { id: account.id, account: { current_password: 'testing', password: 'newpassword' } }
    assert_redirected_to account_path
    _(flash[:success]).must_equal 'Password successfully changed.'
  end
end
