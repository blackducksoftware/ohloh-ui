class SvnClump < Clump

  def scm_class
    OhlohScm::Adapters::SvnChainAdapter
  end

  def url
    "file://#{ path }"
  end
end
