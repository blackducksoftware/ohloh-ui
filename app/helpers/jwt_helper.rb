# frozen_string_literal: true

module JWTHelper
  def build_jwt(user, valid_for_hours = 48)
    exp = Time.now.to_i + (valid_for_hours * 60 * 60)
    payload = { expiration: exp, user: user }
    JWT.encode(payload, ENV.fetch('JWT_SECRET_API_KEY', nil), 'HS256')
  end

  def decode_jwt(jwt)
    decoded_token = JWT.decode(jwt, ENV.fetch('JWT_SECRET_API_KEY', nil), true)
    user = decoded_token[0]['user']

    # Disable the token expiration in 48 hours
    # expiration = decoded_token[0]['expiration']
    # return nil if Time.zone.now > Time.zone.at(expiration)

    Account.find_by(login: user)
  rescue JWT::DecodeError
    'JWT::DecodeError'
  end

  def authenticate_jwt
    account = decode_jwt(params[:JWT])
    return jwt_decode_error if account == 'JWT::DecodeError'
    return auth_error unless account.present? && account.access.admin?

    clearance_session.sign_in(account)
  end

  private

  def jwt_decode_error
    render json: { error: 'Invalid authentication token' }, status: :bad_request
  end

  def auth_error
    render json: { error: 'Not an Admin' }, status: :unauthorized
  end
end
