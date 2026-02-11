# frozen_string_literal: true

class GithubUser
  URL_FORMAT = /\A[^\/]+\Z/
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

  def create_subscriptions_for_code_locations(project)
    @code_locations.each do |code_location|
      params = { code_location_id: code_location&.id, client_relation_id: project }
      CodeLocationSubscription.create(params) if code_location.errors.empty?
    end
  end

  private

  def create_code_locations
    # rubocop:disable Naming/MemoizedInstanceVariableName
    @code_locations ||= fetch_repository_urls.map do |url, branch_name|
      CodeLocation.create(url: url, branch: branch_name)
    end

    # rubocop:enable Naming/MemoizedInstanceVariableName
  end

  def fetch_repository_urls
    page = 0
    repository_urls = []

    loop do
      page += 1
      repository_data = get_repository_data(page)
      break if repository_data.blank?

      unforked_repo_data = repository_data.reject { |data| data['fork'] }
      repository_urls.concat(unforked_repo_data.map { |data| [data['html_url'], data['default_branch']] })
    end

    repository_urls
  end

  def get_repository_data(page)
    response = get_github_response(github_uri(page))
    JSON.parse(response.body)
  end

  def get_github_response(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.get(uri.request_uri, authorization: "token #{get_api_key}")
  end

  def github_uri(page)
    URI(GITHUB_API_URL + username + "/repos?page=#{page}&per_page=100")
  end

  def github_username_uri
    URI(GITHUB_API_URL + username)
  end

  def get_api_key
    ENV.fetch('GITHUB_API_BASIC_AUTHENTICATION', nil)
  end

  def username_must_exist
    response = get_github_response(github_username_uri)
    errors.add(:url, I18n.t('invalid_github_username')) unless (200..299).include?(response.code.to_i)
  end
end
