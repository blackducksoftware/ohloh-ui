# frozen_string_literal: true

module JWTHelper
  def build_jwt(user, valid_for_hours = 48)
    exp = Time.now.to_i + (valid_for_hours*60*60)
    payload = { 'expiration': exp,
                'user': user }
    JWT.encode(payload, ENV['JWT_SECRET'], 'HS256')
  end

  def decode_jwt(jwt)
    decoded_token = JWT.decode(jwt, ENV['JWT_SECRET'], true)
    user = decoded_token[0]['user']
    expiration = decoded_token[0]['expiration']

    return nil if Time.zone.now > Time.zone.at(expiration)

    Account.find_by(login: user)
  rescue JWT::DecodeError
    'JWT::DecodeError'
  end

  def jwt_params(params)
    params[:login] = { 'login' => params[:username], 'password' => params[:password], 'remember_me' => '0' }
  end

  def authenticate_jwt
    account = decode_jwt(params[:JWT])
    render json: 'Bad Request', status: bad_request && return if account.nil?

    clearance_session.sign_in(account)
    return unless account.present? && current_user_is_admin?
  end
end
