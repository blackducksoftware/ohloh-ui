class HgClump < Clump
  alias_method :url, :path

  def scm_class
    OhlohScm::Adapters::HglibAdapter
  end
end
