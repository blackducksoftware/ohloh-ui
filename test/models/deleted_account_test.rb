require_relative '../test_helper'

class DeletedAccountTest < ActiveSupport::TestCase
  setup :create_deleted_account

  test 'it should validate the login and email address' do
    deleted_account = build(:deleted_account, email: '', login: '')
    assert_not deleted_account.valid?
    assert_includes deleted_account.errors, :email
    assert_includes deleted_account.errors, :login
  end

  test 'it should find the deleted record of a user' do
    deleted_account = DeletedAccount.find_deleted_account(@account.login)
    assert_not deleted_account.nil?
  end

  test 'it should elapse the time interval of 1 hour' do
    account = create(:deleted_account, created_at: 4.days.ago)
    assert account.feedback_time_elapsed?
  end

  test 'it should not elapse the time interval of 1 hour for newly created records' do
    assert !@account.feedback_time_elapsed?
  end

  test 'it should deliver DeletedAccountNotifier after create' do
    account = build(:deleted_account, created_at: 4.days.ago)
    DeletedAccountNotifier.expects(:deletion).with(account).returns(Mail::Message.new)
    Mail::Message.any_instance.expects(:deliver)

    account.save
  end

  private

  def create_deleted_account
    @account = create(:deleted_account)
  end
end
