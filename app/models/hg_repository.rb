class HgRepository < Repository
  def source_scm_class
    OhlohScm::Adapters::HglibAdapter
  end
end
