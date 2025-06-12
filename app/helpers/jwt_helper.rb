# frozen_string_literal: true

module JwtHelper
  def build_jwt(user, valid_for_hours = 48)
    exp = Time.now.to_i + (valid_for_hours * 60 * 60)
    payload = { expiration: exp,
                user: user }
    JWT.encode(payload, ENV.fetch('JWT_SECRET_API_KEY', nil), 'HS256')
  end

  def decode_jwt(jwt)
    decoded_token = JWT.decode(jwt, ENV.fetch('JWT_SECRET_API_KEY', nil), true)
    user = decoded_token[0]['user']
    expiration = decoded_token[0]['expiration']

    return nil if Time.zone.now > Time.zone.at(expiration)

    Account.find_by(login: user)
  rescue JWT::DecodeError
    'JWT::DecodeError'
  end

  def authenticate_jwt
    account = decode_jwt(params[:JWT])
    if account == 'JWT::DecodeError'
      render json: 'Bad Request', status: :bad_request
      return
    end

    clearance_session.sign_in(account)
    nil unless account.present? && current_user_is_admin?
  end
end
