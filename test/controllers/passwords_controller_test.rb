require 'test_helper'

describe 'PasswordsController' do
  let(:account) { create(:account) }

  it 'must reach password edit route' do
    login_as account
    get :edit, id: account.id
    must_respond_with :ok
  end

  it 'must fail if current password is not provided' do
    login_as account
    put :update, id: account.id, account: { current_password: '', password: 'newpassword', password_confirmation: 'newpassword' }
    must_respond_with :unprocessable_entity
  end

  it 'must fail if current password does not match' do
    login_as account
    put :update, id: account.id, account: { current_password: 'wrongcurrentpassword', password: 'newpassword', password_confirmation: 'newpassword' }
    must_respond_with :unprocessable_entity
  end

  it 'must fail when new password is not provided' do
    login_as account
    put :update, id: account.id, account: { current_password: account.current_password, password: '', password_confirmation: 'newpassword' }
    must_respond_with :unprocessable_entity
  end

  it 'must fail when confirm password is not provided' do
    login_as account
    put :update, id: account.id, account: { current_password: account.current_password, password: 'newpassword', password_confirmation: '' }
    must_respond_with :unprocessable_entity
  end

  it 'must fail when new password and confirm password do not match' do
    login_as account
    put :update, id: account.id, account: { current_password: account.current_password, password: 'newpassword', password_confirmation: 'oldpassword' }
    must_respond_with :unprocessable_entity
  end

  it 'must update password fields' do
    account = create(:account)
    login_as account
    put :update, id: account.id, account: { current_password: account.password, password: 'newpassword', password_confirmation: 'newpassword' }
    must_redirect_to account_path
    flash[:notice].must_equal 'Password successfully changed.'
  end
end