class HgClump < Clump
  alias_method :path, :url

  def scm_class
    OhlohScm::Adapters::HglibAdapter
  end
end
