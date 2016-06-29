class GitRepository < Repository
  def source_scm_class
    OhlohScm::Adapters::GitAdapter
  end
end
