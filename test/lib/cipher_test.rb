require 'test_helper'

class CipherTest < ActiveSupport::TestCase
  describe 'encrypt and decrypt' do
    it 'should encrypt and given data correctly' do
      encrypted_data = Ohloh::Cipher.encrypt('robin')
      encrypted_data.wont_equal 'robin'

      decrypted_data = Ohloh::Cipher.decrypt(encrypted_data)
      decrypted_data.must_equal 'robin'
    end
  end
end
