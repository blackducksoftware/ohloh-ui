class GitRepository < Repository
  def source_scm_class
    OhlohScm::Adapters::GitAdapter
  end

  class << self
    def find_existing(repository)
      GitRepository.find_by(url: repository.url, branch_name: repository.branch_name)
    end

    def dag?
      true
    end
  end
end
