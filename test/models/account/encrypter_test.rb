# frozen_string_literal: true

require 'test_helper'

class Account::EncrypterTest < ActiveSupport::TestCase
  describe 'before_create' do
    it 'must set activation code to random hash' do
      email = Faker::Internet.email
      password = Faker::Internet.password
      account = Account.create!(login: Faker::Name.first_name, email: email, password: password)
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
    it 'must encrypt email when it changes' do
      account = create(:account)
      original_email_md5 = account.email_md5
      email = Faker::Internet.email
      account.email = email
      account.save!

      original_email_md5.wont_equal account.email_md5
    end

    it 'must not encrypt email when it has not changed' do
      account = create(:account)
      account.expects(:encrypt_email).never
      account.save!
    end
  end
end
