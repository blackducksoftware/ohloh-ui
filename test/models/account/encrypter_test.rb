require 'test_helper'

class Account::EncrypterTest < ActiveSupport::TestCase
  class BeforeCreate < Account::EncrypterTest
    test 'must set activation code to random hash' do
      account = create(:account)
      assert_not_empty account.activation_code
      assert_equal 40, account.activation_code.length
      assert_nil account.activation_code.match(/[^a-z0-9]/)
    end

    test 'must populate salt' do
      account = build(:account)
      account.save!

      assert_equal true, account.salt.present?
    end
  end

  class BeforeSave < Account::EncrypterTest
    test 'must not change salt' do
      account = accounts(:user)
      account.password = 'new_password'
      account.password_confirmation = 'new_password'
      original_salt = account.salt

      account.save!

      assert_equal original_salt, account.salt
    end

    test 'must not change crypted_password when password is blank' do
      account = accounts(:uber_data_crawler)
      account.password = nil
      account.password_confirmation = nil
      original_crypted_password = account.crypted_password

      account.save!

      assert_equal original_crypted_password, account.crypted_password
    end

    test 'must change crypted_password if password is not blank' do
      account = accounts(:uber_data_crawler)
      account.password = 'new_password'
      account.password_confirmation = 'new_password'
      original_crypted_password = account.crypted_password

      account.save!

      assert_not_equal original_crypted_password, account.crypted_password
    end

    test 'must encrypt email when it changes' do
      account = accounts(:user)
      original_email_md5 = account.email_md5
      account.email = Faker::Internet.email
      account.save!

      assert_not_equal original_email_md5, account.email_md5
    end

    test 'must not encrypt email when it has not changed' do
      account = accounts(:user)
      account.expects(:encrypt_email).never
      account.save!
    end
  end
end
