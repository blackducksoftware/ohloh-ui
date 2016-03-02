class BzrRepository < Repository
  def source_scm_class
    OhlohScm::Adapters::BzrlibAdapter
  end
end
