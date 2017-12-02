class CodeLocationBuilder
  attr_writer :type, :url, :repo_params, :code_location_params

  class << self
    def build
      builder = new
      yield builder
      builder.code_location
    end
  end

  def code_location
    return repository if repository.is_a?(GithubUser)
    build_code_location
  end

  private

  def repository
    repo_type = @type.constantize
    repo_class = repo_type.get_compatible_class(@url)
    @repository ||= repo_class.new(@repo_params)
  end

  def build_code_location
    CodeLocation.new(@code_location_params.merge(repository: repository))
  end
end
