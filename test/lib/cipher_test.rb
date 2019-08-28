# frozen_string_literal: true

require 'test_helper'

class CipherTest < ActiveSupport::TestCase
  describe 'encrypt and decrypt' do
    it 'should encrypt and given data correctly' do
      encrypted_data = Ohloh::Cipher.encrypt('robin')
      encrypted_data.wont_equal 'robin'
    end
  end

  describe 'decrypt' do
    it 'should encrypt and given data correctly' do
      encrypted_data = Ohloh::Cipher.encrypt('robin')
      decrypted_data = Ohloh::Cipher.decrypt(encrypted_data)
      decrypted_data.must_equal 'robin'
    end

    it 'should return nil if error is thrown' do
      Ohloh::Cipher.decrypt('robin', 'junk_key')
    end
  end
end
