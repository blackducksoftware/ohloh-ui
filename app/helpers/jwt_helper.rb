# frozen_string_literal: true

module JwtHelper
  DEFAULT_JWT_EXPIRY_HOURS = 1

  def build_jwt(user, valid_for_hours = nil)
    valid_for_hours ||= ENV['JWT_EXPIRY_HOURS'].presence&.to_f || DEFAULT_JWT_EXPIRY_HOURS
    exp = Time.now.to_i + (valid_for_hours * 60 * 60)
    payload = { exp: exp, user: user }
    JWT.encode(payload, ENV.fetch('JWT_SECRET_API_KEY', nil), 'HS256')
  end

  def decode_jwt(jwt)
    decoded_token = JWT.decode(jwt, ENV.fetch('JWT_SECRET_API_KEY', nil), true,
                               { algorithm: 'HS256', verify_expiration: true })
    payload = decoded_token[0]
    validate_token_expiration!(payload)
    Account.find_by(login: payload['user'])
  rescue JWT::ExpiredSignature
    'JWT::ExpiredSignature'
  rescue JWT::DecodeError
    'JWT::DecodeError'
  end

  def authenticate_jwt
    account = decode_jwt(params[:JWT])
    return jwt_expired_error if account == 'JWT::ExpiredSignature'
    return jwt_decode_error if account == 'JWT::DecodeError'
    return auth_error unless account.present? && account.access.admin?

    clearance_session.sign_in(account)
  end

  private

  def validate_token_expiration!(payload)
    raise JWT::ExpiredSignature, 'Token missing expiration claim' unless payload['exp'] || payload['expiration']
    return unless payload['expiration']

    exp_time = Time.at(payload['expiration']).to_i
    raise JWT::ExpiredSignature, 'Token expiration field has expired' if exp_time < Time.now.to_i
  end

  def jwt_expired_error
    render json: { error: 'Authentication token has expired' }, status: :unauthorized
  end

  def jwt_decode_error
    render json: { error: 'Invalid authentication token' }, status: :bad_request
  end

  def auth_error
    render json: { error: 'Not an Admin' }, status: :unauthorized
  end
end
