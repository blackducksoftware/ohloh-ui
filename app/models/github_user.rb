class GithubUser
  URL_FORMAT = /\A[^\/]+\Z/
  include ActiveModel::Model

  attr_accessor :url, :bypass_url_validation
  attr_reader :code_locations, :module_branch_name, :password
  alias_method :username, :url

  validates :url, format: { with: URL_FORMAT, message: I18n.t('invalid_github_username') }
  validate :username_must_exist, if: -> { url.match(URL_FORMAT) }

  def attributes
    { url: username, type: self.class.name }
  end

  def save!
    create_code_locations
  end

  def create_enlistment_for_project(editor_account, project, ignore = nil)
    code_locations.each do |code_location|
      code_location.create_enlistment_for_project(editor_account, project, ignore) unless code_location.new_record?
    end
  end

  def branch_name
    'master'
  end

  class << self
    def get_compatible_class(_url)
      self
    end
  end

  private

  def create_code_locations
    @code_locations ||= begin
      fetch_repository_urls.collect do |url|
        code_location = CodeLocation.find_existing(url, branch_name)
        unless code_location
          repository = GitRepository.find_or_initialize_by(url: url)
          code_location = CodeLocation.create(repository: repository, module_branch_name: branch_name)
        end
        code_location
      end
    end
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
