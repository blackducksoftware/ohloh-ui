# frozen_string_literal: true

module JwtHelper
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
    token = resolve_jwt_token
    return jwt_decode_error if token.blank?

    account = decode_jwt(token)
    return jwt_decode_error if account == 'JWT::DecodeError'
    return auth_error unless account.present? && account.access.admin?

    clearance_session.sign_in(account)
  end

  private

  def resolve_jwt_token
    token = bearer_token

    # Fall back to query parameter (deprecated method)
    if token.blank? && params[:JWT].present?
      token = params[:JWT]
      log_deprecation_warning(
        'JWT token should be passed in Authorization header as "Bearer <token>" instead of query parameter. ' \
        'This method is deprecated and will be removed. Please update within 3 months.'
      )
    end

    token
  end

  def jwt_decode_error
    render_jwt_error('Invalid authentication token', :bad_request)
  end

  def auth_error
    render_jwt_error('Not an Admin', :unauthorized)
  end

  def render_jwt_error(message, status)
    response_body = { error: message }
    if @deprecation_warning.present?
      response_body[:deprecation_warning] = @deprecation_warning
      response_body[:deprecation_deadline] = @deprecation_deadline
    end
    render json: response_body, status: status
  end
end
