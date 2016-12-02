class GitRepository < Repository
  def source_scm_class
    OhlohScm::Adapters::GitAdapter
  end

  class << self
    def dag?
      true
    end
  end
end
