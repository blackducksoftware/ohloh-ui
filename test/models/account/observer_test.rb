require 'test_helper'
class Account::ObserverTest < ActiveSupport::TestCase
  fixtures :accounts, :invites
  test 'before validation' do
    account = accounts(:user)
    account.login = 'login    '
    account.email = '     email'
    account.name = '    name    '
    Account::Observer.new(account).before_validation
    assert_equal 'login', account.login
    assert_equal 'email', account.email
    assert_equal 'name', account.name
  end

  test 'before create' do
    account = accounts(:user)
    Account::Observer.new(account).before_create
    assert_not_empty account.activation_code
    assert_equal 40, account.activation_code.length
    assert_nil account.activation_code.match(/[^a-z0-9]/)
  end

  test 'should create person after create' do
    account = accounts(:uber_data_crawler)
    account.no_email = false
    assert_difference('Person.count', 1) do
      Account::Observer.new(account).after_create
    end
  end

  test 'should rollback when notification raises an error' do
    account = accounts(:uber_data_crawler)
    account.no_email = true
    AccountNotifier.stubs(:deliver_signup_notification).raises(Net::SMTPSyntaxError.new('Bad recipient address syntax'))
    assert_no_difference('Person.count') do
      Account.transaction do
        Account::Observer.new(account).after_create
      end
    end
    assert_equal 1, account.errors.size
    assert_equal ["The Black Duck Open Hub could not send registration email to <strong class='red'>uber@ohloh.net</strong>. Invalid Email Address provided."], account.errors['email']
  end

  test 'should not create person for spam account' do
    account = accounts(:spammer)
    account.no_email = false
    assert_no_difference('Person.count') do
      Account::Observer.new(account).after_create
    end
  end

  test 'should change invitee id and activated date' do
    account = accounts(:uber_data_crawler)
    account.no_email = false
    invite = invites(:user)
    invitee_id = invite.invitee_id
    account.invite_code = invite.activation_code
    Account::Observer.new(account).after_create
    assert_not_equal invites(:user).reload.invitee_id, invitee_id
    assert_equal invites(:user).invitee_id, account.id
  end

  test 'should not change if password is blank' do
    account = accounts(:uber_data_crawler)
    assert_equal '7e3041ebc2fc05a40c60028e2c4901a81035d3cd', account.salt
    assert_equal '00742970dc9e6319f8019fd54864d3ea740f04b1', account.crypted_password
    assert_equal '9dbaca493199c57710e53b56310f6581', account.email_md5
    Account::Observer.new(account).before_Save
    assert_equal '7e3041ebc2fc05a40c60028e2c4901a81035d3cd', account.salt
    assert_equal '00742970dc9e6319f8019fd54864d3ea740f04b1', account.crypted_password
    assert_equal '9dbaca493199c57710e53b56310f6581', account.email_md5
  end

  test 'should change if password is not blank' do
    account = accounts(:uber_data_crawler)
    account.password = 'testpassword'
    assert_equal '7e3041ebc2fc05a40c60028e2c4901a81035d3cd', account.salt
    assert_equal '00742970dc9e6319f8019fd54864d3ea740f04b1', account.crypted_password
    assert_equal '9dbaca493199c57710e53b56310f6581', account.email_md5
    Account::Observer.new(account).before_Save
    assert_equal '7e3041ebc2fc05a40c60028e2c4901a81035d3cd', account.salt
    assert_equal '6ed58e4f51f6e32a6d11b66400c3059c989aaff2', account.crypted_password
    assert_equal '135c21feb6a9801c4a8466c394377bd1', account.email_md5
  end

  test 'should change salt only if new record' do
    account = Account.new(accounts(:user).attributes)
    account.password = 'testpassword'
    assert_equal '7e3041ebc2fc05a40c60028e2c4901a81035d3cd', account.salt
    assert_equal '00742970dc9e6319f8019fd54864d3ea740f04b1', account.crypted_password
    assert_equal '63f26c4a00677ea1e8b14d2a56efb104', account.email_md5
    Account::Observer.new(account).before_Save
    assert_not_equal '7e3041ebc2fc05a40c60028e2c4901a81035d3cd', account.salt
    assert_equal '6ed58e4f51f6e32a6d11b66400c3059c989aaff2', account.crypted_password
    assert_equal '135c21feb6a9801c4a8466c394377bd1', account.email_md5
  end
end
