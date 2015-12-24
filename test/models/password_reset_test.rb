require 'test_helper'

class PasswordResetTest < ActiveSupport::TestCase
  let(:account) { create(:account) }

  describe 'validations' do
    it 'must validate for blank emails' do
      password_reset = PasswordReset.new(email: '')
      password_reset.valid?

      password_reset.errors.messages.length.must_equal 1
      password_reset.errors.messages[:email].first.must_match(/required/)
    end

    it 'must accept emails with trailing or leading whitespaces' do
      password_reset = PasswordReset.new(email: "  #{account.email} ")
      password_reset.must_be :valid?
    end
  end

  describe 'new' do
    it 'must assign passed attributes as instance variables' do
      email = Faker::Internet.email
      password_reset = PasswordReset.new(email: email)
      password_reset.instance_variable_get('@email').must_equal email
    end
  end

  describe 'persisted?' do
    it 'wont be a persisted record' do
      password_reset = PasswordReset.new(email: account.email)
      password_reset.wont_be :persisted?
    end
  end

  describe 'refresh_token_and_email_link' do
    before do
      password_reset = PasswordReset.new(email: account.email)
      password_reset.refresh_token_and_email_link
      account.reload
    end

    it 'must set a value for reset_password_tokens' do
      account.reset_password_tokens.must_be :present?
    end

    it 'must set a token in account' do
      account.reset_password_tokens.keys.first.must_be :present?
    end

    it 'must set a timestamp for expiration' do
      timestamp = account.reset_password_tokens.values.first
      timestamp.must_be :<=, Time.current.advance(hours: 4)
      timestamp.must_be :>, Time.current.advance(hours: 3, minutes: 58)
    end
  end
end
