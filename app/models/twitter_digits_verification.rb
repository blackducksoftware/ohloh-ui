class TwitterDigitsVerification < Verification
  attr_accessor :credentials, :service_provider_url

  validates :credentials, :service_provider_url, presence: true

  before_validation :generate_auth_id, on: :create

  private

  def generate_auth_id
    response = http.get2(uri.path, 'Authorization' => credentials)

    self.auth_id = JSON.parse(response.body)['id_str'] if response.code == '200'
  end

  def uri
    @uri ||= URI(service_provider_url)
  end

  def http
    Net::HTTP.new(uri.host, uri.port).tap { |http| http.use_ssl = true }
  end
end
