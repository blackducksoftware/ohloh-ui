class CvsRepository < Repository
  def source_scm_class
    OhlohScm::Adapters::CvsAdapter
  end

  def branch_or_module_name
    :module_name
  end
end
