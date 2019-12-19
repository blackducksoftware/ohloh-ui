# frozen_string_literal: true

require_relative '../test_helper'

class DeletedAccountTest < ActiveSupport::TestCase
  setup :create_deleted_account

  it 'it should validate the login and email address' do
    deleted_account = build(:deleted_account, email: '', login: '')
    deleted_account.valid?.must_equal false
    deleted_account.valid?.must_equal false
    deleted_account.errors.must_include :email
    deleted_account.errors.must_include :login
  end

  it 'it should find the deleted record of a user' do
    deleted_account = DeletedAccount.find_deleted_account(@account.login)
    deleted_account.wont_be_nil
  end

  it 'it should elapse the time interval of 1 hour' do
    account = create(:deleted_account, created_at: 4.days.ago)
    account.feedback_time_elapsed?.must_equal true
  end

  it 'it should not elapse the time interval of 1 hour for newly created records' do
    @account.feedback_time_elapsed?.must_equal false
  end

  it 'it should deliver DeletedAccountNotifier after create' do
    account = build(:deleted_account, created_at: 4.days.ago)
    DeletedAccountNotifier.expects(:deletion).with(account).returns(Mail::Message.new)
    Mail::Message.any_instance.expects(:deliver)

    account.save
  end

  it 'it should return login attribute instead of id' do
    @account.to_param.must_equal @account.login
  end

  private

  def create_deleted_account
    @account = create(:deleted_account)
  end
end
