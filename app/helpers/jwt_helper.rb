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
      log_jwt_deprecation_warning
    end

    token
  end

  def bearer_token
    auth_header = request.headers['Authorization']
    return nil unless auth_header&.start_with?('Bearer ')

    auth_header.split('Bearer ', 2).last.presence
  end

  def log_jwt_deprecation_warning
    message = 'JWT token should be passed in Authorization header as "Bearer <token>" instead of query parameter. ' \
              'This method is deprecated and will be removed. Please update within 3 months.'
    @deprecation_warning = message
    @deprecation_deadline = 3.months.from_now.to_date.iso8601
    logger.warn("[DEPRECATED] #{message}")
    response.headers['X-Deprecation-Warning'] = message
    response.headers['X-Deprecation-Deadline'] = @deprecation_deadline
  end

  def jwt_decode_error
    response_body = { error: 'Invalid authentication token' }
    if @deprecation_warning.present?
      response_body[:deprecation_warning] = @deprecation_warning
      response_body[:deprecation_deadline] = @deprecation_deadline
    end
    render json: response_body, status: :bad_request
  end

  def auth_error
    response_body = { error: 'Not an Admin' }
    if @deprecation_warning.present?
      response_body[:deprecation_warning] = @deprecation_warning
      response_body[:deprecation_deadline] = @deprecation_deadline
    end
    render json: response_body, status: :unauthorized
  end
end
