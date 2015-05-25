require 'test_helper'

describe 'PasswordsController' do
  it 'must reach password edit route' do
    account = create(:account)
    login_as account
    get :edit, id: account.id
    must_respond_with :ok
  end

  it 'must fail to update if all fields are blank' do
    account = create(:account, password: 'testing', password_confirmation: 'testing')
    login_as account
    put :update, id: account.id, account: { current_password: '', password: '', password_confirmation: '' }
    must_respond_with :unprocessable_entity
    flash[:error].must_equal 'There was a problem saving!'
  end

  it 'must fail if current password is not provided' do
    account = create(:account, password: 'testing', password_confirmation: 'testing')
    login_as account
    put :update, id: account.id, account: { current_password: '',
                                            password: 'newpassword',
                                            password_confirmation: 'newpassword' }
    must_respond_with :unprocessable_entity
    flash[:error].must_equal 'There was a problem saving!'
  end

  it 'must fail if current password does not match' do
    account = create(:account, password: 'testing', password_confirmation: 'testing')
    login_as account
    put :update, id: account.id, account: { current_password: 'wrongcurrentpassword',
                                            password: 'newpassword',
                                            password_confirmation: 'newpassword' }
    must_respond_with :unprocessable_entity
    flash[:error].must_equal 'There was a problem saving!'
  end

  it 'must fail when new password is not provided' do
    account = create(:account, password: 'testing', password_confirmation: 'testing')
    login_as account
    put :update, id: account.id, account: { current_password: 'testing',
                                            password: '',
                                            password_confirmation: 'newpassword' }
    must_respond_with :unprocessable_entity
    flash[:error].must_equal 'There was a problem saving!'
  end

  it 'must fail when confirm password is not provided' do
    account = create(:account, password: 'testing', password_confirmation: 'testing')
    login_as account
    put :update, id: account.id, account: { current_password: 'testing',
                                            password: 'newpassword',
                                            password_confirmation: '' }
    must_respond_with :unprocessable_entity
    flash[:error].must_equal 'There was a problem saving!'
  end

  it 'must fail when new password and confirm password do not match' do
    account = create(:account, password: 'testing', password_confirmation: 'testing')
    login_as account
    put :update, id: account.id, account: { current_password: 'testing',
                                            password: 'newpassword',
                                            password_confirmation: 'oldpassword' }
    must_respond_with :unprocessable_entity
    flash[:error].must_equal 'There was a problem saving!'
  end

  it 'must fail if new password is less than 5 characters' do
    account = create(:account, password: 'testing', password_confirmation: 'testing')
    login_as account
    put :update, id: account.id, account: { current_password: 'testing',
                                            password: 'abc', password_confirmation: 'abc' }
    must_respond_with :unprocessable_entity
    flash[:error].must_equal 'There was a problem saving!'
  end

  it 'must fail if new password is more than 40 characters' do
    account = create(:account, password: 'testing', password_confirmation: 'testing')
    login_as account
    password = 'averylongpasswordthatiswaymorethanfortycharactersandshouldfailwhensubmitted'
    put :update, id: account.id, account: { current_password: 'testing',
                                            password: password, password_confirmation: password }
    must_respond_with :unprocessable_entity
    flash[:error].must_equal 'There was a problem saving!'
  end

  it 'must update password fields' do
    account = create(:account, password: 'testing', password_confirmation: 'testing')
    login_as account
    put :update, id: account.id, account: { current_password: 'testing',
                                            password: 'newpassword',
                                            password_confirmation: 'newpassword' }
    must_redirect_to account_path
    flash[:success].must_equal 'Password successfully changed.'
  end
end
