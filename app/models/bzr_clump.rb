class BzrClump < Clump
  alias_method :path, :url

  def scm_class
    OhlohScm::Adapters::BzrlibAdapter
  end
end

