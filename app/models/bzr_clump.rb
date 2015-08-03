class BzrClump < Clump
  alias_method :url, :path

  def scm_class
    OhlohScm::Adapters::BzrlibAdapter
  end
end
