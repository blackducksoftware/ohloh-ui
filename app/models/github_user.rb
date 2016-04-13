class GithubUser
  URL_FORMAT = /\A[^\/]+\Z/
  include ActiveModel::Model

  attr_accessor :url, :bypass_url_validation
  attr_reader :repositories, :module_name, :password
  alias_method :username, :url

  validates :url, format: { with: URL_FORMAT, message: I18n.t('invalid_github_username') }
  validate :username_must_exist, if: -> { url.match(URL_FORMAT) }

  def attributes
    { url: username, type: self.class.name }
  end

  def save!
    create_repositories
  end

  def create_enlistment_for_project(editor_account, project, ignore = nil)
    repositories.each do |repository|
      repository.create_enlistment_for_project(editor_account, project, ignore)
    end
  end

  def branch_name
    :master
  end

  class << self
    def get_compatible_class(_url)
      self
    end

    def find_existing(_repository)
    end

    def find_existing_repository(url)
      GitRepository.find_by(url: url, branch_name: new.branch_name)
    end
  end

  private

  def create_repositories
    urls = fetch_repository_urls
    @repositories ||= urls.map { |url| GitRepository.find_or_create_by(url: url, branch_name: branch_name) }
  end

  def fetch_repository_urls
    page = 0
    repository_urls = []

    loop do
      page += 1
      _stdin, json_repository_data = Open3.popen3('curl', github_url(page))
      repository_data = JSON.load(json_repository_data)
      break unless repository_data.present?
      repository_urls.concat repository_data.map { |data| data['git_url'] }
    end

    repository_urls
  end

  def github_url(page)
    "#{github_username_url}/repos?page=#{page}&per_page=100"
  end

  def github_username_url
    "https://api.github.com/users/#{username}"
  end

  def username_must_exist
    _stdin, stdout = Open3.popen3('curl', github_username_url)
    output = JSON.load(stdout)
    errors.add(:url, I18n.t('invalid_github_username')) if output.is_a?(Hash) && output['message'] == 'Not Found'
  end
end
