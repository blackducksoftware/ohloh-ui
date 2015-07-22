class BzrClump < Clump

  def scm_class
    OhlohScm::Adapters::BzrlibAdapter
  end

  def url
    if self.slave.local?
      self.path
    else
      "bzr+ssh://#{self.slave.hostname}#{self.path}"
    end
  end
end

