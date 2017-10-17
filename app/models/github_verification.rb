class GithubVerification < Verification
  attr_accessor :code

  validates :code, presence: true

  before_validation :generate_access_token, on: :create

  private

  def generate_access_token
    response = request.send_request('POST', uri.path, data)
    data = CGI.parse(response.body)
    self.auth_id = data['access_token'].first if response.code == '200'
  end

  def request
    Net::HTTP.new(uri.host, uri.port).tap { |http| http.use_ssl = true }
  end

  def uri
    @uri ||= URI(ENV['GITHUB_ACCESS_TOKEN_URI'])
  end

  def data
    CGI.unescape({ code: code, client_id: ENV['GITHUB_CLIENT_ID'], client_secret: ENV['GITHUB_CLIENT_SECRET'],
                   redirect_uri: ENV['GITHUB_REDIRECT_URI'] }.to_query)
  end
end
