class GitClump < Clump

  def branch_name
    if self.code_set.repository.source_scm_class != OhlohScm::Adapters::GitAdapter || super.to_s.blank?
      'master'
    else
      super
    end
  end

  def url
    if self.slave.local?
      self.path
    else
      self.slave.hostname + ':' + self.path
    end
  end
end
