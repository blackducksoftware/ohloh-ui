# frozen_string_literal: true

require 'jwt'
require 'net/http'

class FirebaseService
  VALID_JWT_PUBLIC_KEYS_RESPONSE_CACHE_KEY = 'firebase_phone_jwt_public_keys_cache_key'
  JWT_ALGORITHM = 'RS256'

  def initialize(firebase_project_id)
    @firebase_project_id = firebase_project_id
  end

  def decode(id_token)
    decoded_token = FirebaseService.decode_jwt_token(id_token, @firebase_project_id, nil)
    return nil unless decoded_token

    valid_public_keys = FirebaseService.retrieve_and_cache_jwt_valid_public_keys
    return nil unless check_validations(decoded_token, valid_public_keys.keys)

    kid = decoded_token[1]['kid']
    public_key = OpenSSL::X509::Certificate.new(valid_public_keys[kid]).public_key
    FirebaseService.decode_jwt_token(id_token, @firebase_project_id, public_key)
  end

  def check_validations(token, valid_public_keys)
    payload = token[0]
    headers = token[1]
    valid_algorithm?(headers['alg']) && valid_kid_key?(headers['kid'], valid_public_keys) && valid_sub?(payload['sub'])
  end

  def valid_algorithm?(alg)
    flag = true
    if alg != JWT_ALGORITHM
      Rails.logger.info("Invalid access token 'alg' header (#{alg}). Must be '#{JWT_ALGORITHM}'.")
      flag = false
    end
    flag
  end

  def valid_kid_key?(kid, valid_keys)
    flag = true
    unless valid_keys.include?(kid)
      Rails.logger.info("Invalid access token 'kid' header, do not correspond to valid public keys.")
      flag = false
    end
    flag
  end

  def valid_sub?(sub)
    flag = true
    if sub.blank?
      Rails.logger.info("Invalid access token. 'Subject' (sub) must be a non-empty string.")
      flag = false
    end
    flag
  end

  def self.get_custom_options(firebase_project_id)
    { verify_iat: true,
      verify_aud: true, aud: firebase_project_id,
      verify_iss: true,
      iss: "https://securetoken.google.com/#{firebase_project_id}" }
  end

  def self.decode_jwt_token(firebase_jwt_token, firebase_project_id, public_key)
    custom_options = get_custom_options(firebase_project_id)
    custom_options[:algorithm] = JWT_ALGORITHM unless public_key.nil?
    begin
      decoded_token = JWT.decode(firebase_jwt_token, public_key, !public_key.nil?, custom_options)
    rescue StandardError => e
      Rails.logger.info("#{e.class} message: #{e.message}")
      return nil
    end
    decoded_token
  end

  def self.retrieve_and_cache_jwt_valid_public_keys
    valid_public_keys = Rails.cache.read(VALID_JWT_PUBLIC_KEYS_RESPONSE_CACHE_KEY)
    if valid_public_keys.nil?
      response = fetch_keys
      valid_public_keys = response[0]
      cc = response[1]['cache-control']
      max_age = cc[/max-age=(\d+?),/m, 1]

      Rails.cache.write(VALID_JWT_PUBLIC_KEYS_RESPONSE_CACHE_KEY, valid_public_keys, expires_in: max_age.to_i)
    end
    valid_public_keys
  end

  def self.fetch_keys
    uri = URI('https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com')
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Get.new(uri.path)
    response = https.request(req)
    raise "Something went wrong: can't obtain valid JWT public keys from Google." if response.code != '200'

    [JSON.parse(response.body), response]
  end
end
