# frozen_string_literal: true

class GithubUser
  URL_FORMAT = /\A[^\/]+\Z/.freeze
  GITHUB_API_URL = 'https://api.github.com/users/'
  include ActiveModel::Model

  attr_accessor :url
  alias username url

  validates :url, format: { with: URL_FORMAT, message: I18n.t('invalid_github_username') }
  validate :username_must_exist, if: -> { url.match(URL_FORMAT) }

  def attributes
    { url: username, scm_type: self.class.name }
  end

  def save!
    create_code_locations
  end

  def create_enlistment_for_project(editor_account, project, ignore = nil)
    project = Project.find(project)
    editor_account = Account.find(editor_account)
    @code_locations.each do |code_location|
      code_location.create_enlistment_for_project(editor_account, project, ignore) if code_location.errors.empty?
    end
  end

  private

  def create_code_locations
    # rubocop:disable Naming/MemoizedInstanceVariableName
    @code_locations ||= begin
      fetch_repository_urls.map do |url, branch_name|
        CodeLocation.create(url: url, branch: branch_name)
      end
    end
    # rubocop:enable Naming/MemoizedInstanceVariableName
  end

  def fetch_repository_urls
    page = 0
    repository_urls = []

    loop do
      page += 1
      repository_data = get_github_response(URI(github_url(page)))
      break if repository_data.blank?

      repository_urls.concat(repository_data.map { |data| [data['html_url'], data['default_branch']] })
    end

    repository_urls
  end

  def get_github_response(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.get(uri.request_uri, authorization: "token #{get_api_key}")
    JSON.parse(response.body)
  end

  def github_url(page)
    GITHUB_API_URL + username + "/repos?page=#{page}&per_page=100"
  end

  def github_username_url
    GITHUB_API_URL + username + "?access_token=#{get_api_key}"
  end

  def get_api_key
    ENV['GITHUB_API_BASIC_AUTHENTICATION']
  end

  def username_must_exist
    _stdin, stdout = Open3.popen3('curl', github_username_url)
    output = JSON.parse(stdout.read)
    errors.add(:url, I18n.t('invalid_github_username')) if output.is_a?(Hash) && output['message'] == 'Not Found'
  end
end
