class SvnRepository < Repository
  def source_scm_class
    OhlohScm::Adapters::SvnChainAdapter
  end
end
