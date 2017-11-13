require 'test_helper'

class PasswordStrategyTest < ActiveSupport::TestCase
  describe 'password=' do
    it 'must create new salt for new password' do
      old_password = :testing
      account = create(:account, password: old_password, password_confirmation: old_password)
      original_salt = account.salt
      new_password = :new_password
      account.update!(password: new_password, password_confirmation: new_password,
                      current_password: old_password)
      account.salt.wont_equal original_salt
    end

    it 'wont change encrypted_password when updating blank password' do
      password = :testing
      account = create(:account, password: password, password_confirmation: password)
      account.update!(password: nil, password_confirmation: nil,
                      current_password: password)
      original_crypted_password = account.encrypted_password

      account.save!

      account.encrypted_password.must_equal original_crypted_password
    end

    it 'must change encrypted_password when password is not blank' do
      old_password = :testing
      account = create(:account, password: old_password, password_confirmation: old_password)
      original_encrypted_password = account.encrypted_password
      new_password = :new_password

      account.update!(password: new_password, password_confirmation: new_password,
                      current_password: old_password)

      original_encrypted_password.wont_equal account.encrypted_password
    end
  end
end
