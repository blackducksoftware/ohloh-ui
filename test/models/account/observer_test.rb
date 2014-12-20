require 'test_helper'
class Account::ObserverTest < ActiveSupport::TestCase
  fixtures :accounts, :invites

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
    skip('TODO: AccountNotifier')
    account = accounts(:uber_data_crawler)
    account.no_email = true
    AccountNotifier.stubs(:deliver_signup_notification).raises(Net::SMTPSyntaxError.new('Bad recipient address syntax'))
    assert_no_difference('Person.count') do
      Account.transaction do
        Account::Observer.new(account).after_create
      end
    end
    assert_equal 1, account.errors.size
    # assert_equal ["The Black Duck Open Hub could not send
    # registration email to <strong class='red'>uber@ohloh.net</strong>.
    # Invalid Email Address provided."], account.errors['email']
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
    Account::Observer.new(account).before_save
    assert_equal '7e3041ebc2fc05a40c60028e2c4901a81035d3cd', account.salt
    assert_equal '302a770abbfed35c52bbdd82436af94d50363ae0', account.crypted_password
    assert_equal '135c21feb6a9801c4a8466c394377bd1', account.email_md5
  end

  test 'should change if password is not blank' do
    account = accounts(:uber_data_crawler)
    account.password = 'testpassword'
    assert_equal '7e3041ebc2fc05a40c60028e2c4901a81035d3cd', account.salt
    assert_equal '00742970dc9e6319f8019fd54864d3ea740f04b1', account.crypted_password
    assert_equal '9dbaca493199c57710e53b56310f6581', account.email_md5
    Account::Observer.new(account).before_save
    assert_equal '7e3041ebc2fc05a40c60028e2c4901a81035d3cd', account.salt
    assert_equal '6ed58e4f51f6e32a6d11b66400c3059c989aaff2', account.crypted_password
    assert_equal '135c21feb6a9801c4a8466c394377bd1', account.email_md5
  end

  test 'should change salt only if new record' do
    account = Account.new(accounts(:uber_data_crawler).attributes)
    account.password = 'testpassword'
    assert_equal '7e3041ebc2fc05a40c60028e2c4901a81035d3cd', account.salt
    assert_equal '00742970dc9e6319f8019fd54864d3ea740f04b1', account.crypted_password
    assert_equal '9dbaca493199c57710e53b56310f6581', account.email_md5
    Account::Observer.new(account).before_save
    assert_not_equal '7e3041ebc2fc05a40c60028e2c4901a81035d3cd', account.salt
    assert_not_equal '6ed58e4f51f6e32a6d11b66400c3059c989aaff2', account.crypted_password
    assert_equal '135c21feb6a9801c4a8466c394377bd1', account.email_md5
  end

  test 'should update persons effective_name after save' do
    account = accounts(:user)
    assert_equal 'Robin Luckey', account.person.effective_name
    Account::Observer.new(account).after_save
    assert_equal account.name, account.person.effective_name
  end

  test 'should schedule orgs analysis on update' do
    skip('TODO: organization schedule analysis')
    Account::Observer.new(account).after_update
  end

  test 'should destroy dependencies when marked as spam' do
    account = accounts(:user)
    Account::Authorize.any_instance.stubs(:spam?).returns(true)
    account.topics.update_all(posts_count: 0)
    assert_equal 3, account.topics.count
    assert_not_nil account.person
    assert_equal 1, account.positions.count
    Account::Observer.new(account).after_update
    account.reload
    assert_equal 0, account.topics.count
    assert_nil account.person
    assert_equal 0, account.positions.count
  end

  test 'should rollback when destroy dependencies raises an exception' do
    account = accounts(:user)
    Account::Authorize.any_instance.stubs(:spam?).returns(true)
    Account.any_instance.stubs(:api_keys).raises(ActiveRecord::Rollback)
    account.topics.update_all(posts_count: 0)
    assert_equal 3, account.topics.count
    assert_not_nil account.person
    assert_equal 1, account.positions.count
    Account.transaction do
      Account::Observer.new(account).after_update
    end
    account.reload
    assert_equal 3, account.topics.count
    assert_not_nil account.person
    assert_equal 1, account.positions.count
  end

  test 'should destroy dependencies before account destroy' do
    account = accounts(:user)
    assert_equal 1, account.positions.count
    assert_equal 5, account.posts.count
    assert_equal 0, Account.find_or_create_anonymous_account.posts.count
    assert_difference('DeletedAccount.count', 1) do
      Account::Observer.new(account).before_destroy
    end
    assert_equal 0, account.positions.count
    assert_equal 0, account.posts.count
    assert_equal 5, Account.find_or_create_anonymous_account.posts.count
  end
end
