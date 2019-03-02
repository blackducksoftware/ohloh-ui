module Ohloh
  class Cipher
    class << self
      def default_key
        Base64.decode64(ENV['OHLOH_CIPHER_KEY'])
      end

      def encrypt(data, key = default_key)
        aes = OpenSSL::Cipher.new('AES-256-CBC')
        aes.encrypt
        aes.key = key
        CGI.escape(Base64.encode64(aes.update(data) + aes.final))
      end

      def decrypt(data, key = default_key)
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
end
