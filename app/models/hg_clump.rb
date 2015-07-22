class HgClump < Clump

  def scm_class
    OhlohScm::Adapters::HglibAdapter
  end

  def url
    if self.slave.local?
      self.path
    else
      "ssh://#{self.slave.hostname}/#{self.path}"
    end
  end
end
