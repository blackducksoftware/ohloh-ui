# frozen_string_literal: true

module JWTHelper
  def build_jwt(user, valid_for_hours = 48)
    exp = Time.now.to_i + (valid_for_hours * 60 * 60)
    payload = { expiration: exp,
                user: user }
    JWT.encode(payload, ENV['JWT_SECRET_API_KEY'], 'HS256')
  end

  def decode_jwt(jwt)
    decoded_token = JWT.decode(jwt, ENV['JWT_SECRET_API_KEY'], true)
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
    return unless account.present? && current_user_is_admin?
  end
end
