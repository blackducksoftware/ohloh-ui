class CodeLocationBuilder
  attr_writer :type, :url, :repo_params

  class << self
    def build
      builder = new
      yield builder
      builder.code_location
    end
  end

  def code_location
    return repository if repository.is_a?(GithubUser)
    find_or_build_code_location
  end

  def code_location_params=(params)
    @code_location_params = params || {}
  end

  private

  def repository
    repo_type = @type.constantize
    repo_class = repo_type.get_compatible_class(@url)
    @repository ||= repo_class.create_with(@repo_params).find_or_initialize_by(url: @repo_params[:url])
  end

  def code_location_parameters
    @code_location_params.merge(repository: repository)
  end

  def set_repo_username_and_password(code_location)
    repository = code_location.repository
    repository.username = @repo_params[:username]
    repository.password = @repo_params[:password]
    code_location
  end

  def find_or_build_code_location
    code_location = CodeLocation.find_existing(repository.url, @code_location_params[:module_branch_name])
    return set_repo_username_and_password(code_location) if code_location.present?
    CodeLocation.new(code_location_parameters)
  end
end
