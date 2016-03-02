class GitRepository < Repository
  def source_scm_class
    OhlohScm::Adapters::GitAdapter
  end

  class << self
    def find_existing(repository)
      GitRepository.where(url: repository.url, branch_name: repository.branch_name).first
    end
  end
end
