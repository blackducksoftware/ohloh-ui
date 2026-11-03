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
    token = resolve_jwt_token
    return jwt_decode_error if token.blank?
   
    account = decode_jwt(token)
    return jwt_decode_error if account == 'JWT::DecodeError'
    return jwt_expired_error if account == 'JWT::ExpiredSignature'
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
