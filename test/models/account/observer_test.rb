require 'test_helper'
class Account::ObserverTest < ActiveSupport::TestCase
  fixtures :accounts, :invites

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
