# frozen_string_literal: true

require 'test_helper'

class AlterPasswordsControllerTest < ActionController::TestCase
  it 'must reach password edit route' do
    account = create(:account)
    login_as account
    get :edit, params: { id: account.login }
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
    put :update, params: { id: account.login, account: { current_password: '', password: '' } }
    assert_response :unprocessable_entity
    _(flash[:error]).must_equal 'There was a problem saving!'
  end

  it 'must fail if current password is not provided' do
    account = create(:account, password: 'testing')
    login_as account
    put :update, params: { id: account.login, account: { current_password: '', password: 'newpassword' } }
    assert_response :unprocessable_entity
    _(flash[:error]).must_equal 'There was a problem saving!'
  end

  it 'must fail if current password does not match' do
    account = create(:account, password: 'testing')
    login_as account
    put :update,
        params: { id: account.login, account: { current_password: 'wrongcurrentpassword', password: 'newpassword' } }
    assert_response :unprocessable_entity
    _(flash[:error]).must_equal 'There was a problem saving!'
  end

  it 'must fail when new password is not provided' do
    account = create(:account, password: 'testing')
    login_as account
    put :update, params: { id: account.login, account: { current_password: 'testing', password: '' } }
    assert_response :unprocessable_entity
    _(flash[:error]).must_equal 'There was a problem saving!'
  end

  it 'must fail if new password is less than 5 characters' do
    account = create(:account, password: 'testing')
    login_as account
    put :update, params: { id: account.login, account: { current_password: 'testing', password: 'abc' } }
    assert_response :unprocessable_entity
    _(flash[:error]).must_equal 'There was a problem saving!'
  end

  it 'must fail if new password is more than 40 characters' do
    account = create(:account, password: 'testing')
    login_as account
    password = 'averylongpasswordthatiswaymorethanfortycharactersandshouldfailwhensubmitted'
    put :update, params: { id: account.login, account: { current_password: 'testing', password: password } }
    assert_response :unprocessable_entity
    _(flash[:error]).must_equal 'There was a problem saving!'
  end

  it 'must update password fields' do
    account = create(:account, password: 'testing')
    login_as account
    put :update, params: { id: account.login, account: { current_password: 'testing', password: 'newpassword' } }
    assert_redirected_to account_path
    _(flash[:success]).must_equal 'Password successfully changed.'
  end

  describe 'authentication and authorization' do
    it 'must redirect to login when not authenticated' do
      account = create(:account)
      get :edit, params: { id: account.login }
      assert_redirected_to new_session_path
    end

    it 'must redirect unverified accounts' do
      unverified_account = create(:account, activated_at: nil)
      login_as unverified_account

      get :edit, params: { id: unverified_account.login }
      assert_response :redirect
    end
  end

  describe 'private methods' do
    let(:account) { create(:account) }
    let(:controller) { AlterPasswordsController.new }

    it 'should set current_user as account' do
      controller.stubs(:current_user).returns(account)
      controller.send(:set_account)
      _(controller.instance_variable_get(:@account)).must_equal account
    end

    it 'should enforce account ownership with login' do
      controller.params = { id: account.login }
      controller.instance_variable_set(:@account, account)
      # Should not raise error
      controller.send(:must_own_account)
    end

    it 'should enforce account ownership with me' do
      controller.params = { id: 'me' }
      controller.instance_variable_set(:@account, account)
      # Should not raise error
      controller.send(:must_own_account)
    end

    it 'should deny access for wrong account' do
      other_account = create(:account)
      controller.params = { id: other_account.login }
      controller.instance_variable_set(:@account, account)
      controller.expects(:access_denied)
      controller.send(:must_own_account)
    end

    it 'should permit only allowed parameters' do
      controller.params = ActionController::Parameters.new(
        account: {
          current_password: 'old',
          password: 'new',
          forbidden_param: 'hacker'
        }
      )

      permitted = controller.send(:account_params)
      _(permitted.keys).must_equal %w[current_password password]
      _(permitted[:forbidden_param]).must_be_nil
    end
  end

  describe 'edge cases' do
    it 'must preserve validate_current_password flag' do
      account = create(:account, password: 'testing')
      login_as account

      put :update, params: {
        id: account.login,
        account: { current_password: 'testing', password: 'newpassword' }
      }

      _(assigns(:account).validate_current_password).must_equal true
    end

    it 'must handle nil password parameter' do
      account = create(:account, password: 'testing')
      login_as account

      put :update, params: {
        id: account.login,
        account: { current_password: 'testing', password: nil }
      }
      assert_response :unprocessable_entity
    end
  end

  describe 'flash messages' do
    it 'must show success flash on password change' do
      account = create(:account, password: 'testing')
      login_as account

      put :update, params: {
        id: account.login,
        account: { current_password: 'testing', password: 'newpassword' }
      }

      _(flash[:success]).must_equal 'Password successfully changed.'
      _(flash[:error]).must_be_nil
    end

    it 'must show error flash on validation failure' do
      account = create(:account, password: 'testing')
      login_as account

      put :update, params: {
        id: account.login,
        account: { current_password: 'wrong', password: 'newpassword' }
      }

      _(flash[:error]).must_equal 'There was a problem saving!'
      _(flash[:success]).must_be_nil
    end
  end
end
