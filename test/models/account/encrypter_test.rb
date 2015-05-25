require 'test_helper'

class Account::EncrypterTest < ActiveSupport::TestCase
  describe 'before_create' do
    it 'must set activation code to random hash' do
      account = create(:account)
      account.activation_code.wont_be_empty
      account.activation_code.length.must_equal 40
      account.activation_code.wont_match(/[^a-z0-9]/)
    end

    it 'must populate salt' do
      account = build(:account)
      account.save!

      account.salt.must_be :present?
    end
  end

  describe 'before_save' do
    it 'must not change salt' do
      account = create(:account, password: 'testing', password_confirmation: 'testing')
      account.password = 'new_password'
      account.password_confirmation = 'new_password'
      account.current_password = 'testing'
      original_salt = account.salt

      account.save!

      account.salt.must_equal original_salt
    end

    it 'must not change crypted_password when password is blank' do
      account = create(:account, password: 'testing', password_confirmation: 'testing')
      account.password = nil
      account.password_confirmation = nil
      account.current_password = 'testing'
      original_crypted_password = account.crypted_password

      account.save!

      account.crypted_password.must_equal original_crypted_password
    end

    it 'must change crypted_password if password is not blank' do
      account = create(:account, password: 'testing', password_confirmation: 'testing')
      account.password = 'new_password'
      account.password_confirmation = 'new_password'
      account.current_password = 'testing'
      original_crypted_password = account.crypted_password

      account.save!

      original_crypted_password.wont_equal account.crypted_password
    end

    it 'must encrypt email when it changes' do
      account = accounts(:user)
      original_email_md5 = account.email_md5
      account.email = Faker::Internet.email
      account.save!

      original_email_md5.wont_equal account.email_md5
    end

    it 'must not encrypt email when it has not changed' do
      account = accounts(:user)
      account.expects(:encrypt_email).never
      account.save!
    end
  end
end
