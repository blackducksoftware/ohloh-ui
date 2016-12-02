class CvsRepository < Repository
  def source_scm_class
    OhlohScm::Adapters::CvsAdapter
  end
end
