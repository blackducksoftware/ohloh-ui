module Ohloh
  class Cipher
    KEY = 'A_TEMPORARY_PLACEHOLDER_KEY_FOR_ENCRYPTION'

    def self.encrypt(data, key = KEY)
      aes = OpenSSL::Cipher.new('AES-256-CBC')
      aes.encrypt
      aes.key = key
      CGI.escape(Base64.encode64(aes.update(data) + aes.final))
    end

    def self.decrypt(data, key = KEY)
      aes = OpenSSL::Cipher.new('AES-256-CBC')
      aes.decrypt
      aes.key = key
      data = Base64.decode64(CGI.unescape(data))
      aes.update(data) + aes.final
      rescue
        nil
    end
  end
end
