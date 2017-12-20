class GithubApi
  GITHUB_USER_URI = 'https://api.github.com/user'.freeze
  GITHUB_ACCESS_TOKEN_URI = 'https://github.com/login/oauth/access_token'.freeze

  def initialize(code)
    @code = code
  end

  def login
    user_response['login']
  end

  def email
    return user_response['email'] if user_response['email']
    fetch_private_email
  end

  def access_token
    return @access_token if @access_token

    response = request.send_request('POST', token_uri.path, config)
    data = CGI.parse(response.body)
    raise StandardError, data['error_description'] if data['error'].present?
    @access_token = data['access_token'].first
  end

  private

  def request
    Net::HTTP.new(token_uri.host, token_uri.port).tap { |http| http.use_ssl = true }
  end

  def user_response
    return @user_response if @user_response

    user_uri = URI(GITHUB_USER_URI)
    @user_response = get_response_using_token(user_uri)
  end

  def config
    CGI.unescape({ code: @code, client_id: ENV['GITHUB_CLIENT_ID'], client_secret: ENV['GITHUB_CLIENT_SECRET'],
                   redirect_uri: ENV['GITHUB_REDIRECT_URI'] }.to_query)
  end

  def token_uri
    @token_uri ||= URI(GITHUB_ACCESS_TOKEN_URI)
  end

  def fetch_private_email
    return @private_email if @private_email
    email_uri = URI(GITHUB_USER_URI + '/emails')
    email_responses = get_response_using_token(email_uri)
    primary_email_response = email_responses.find { |hsh| hsh['primary'] && hsh['verified'] }
    @private_email = primary_email_response['email'] if primary_email_response
  end

  def get_response_using_token(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.get2(uri.path, 'Authorization' => "token #{access_token}")
    JSON.parse(response.body)
  end
end
