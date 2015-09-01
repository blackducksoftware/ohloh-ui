class GitClump < Clump
  alias_method :url, :path

  def branch_name
    if code_set.repository.source_scm_class != OhlohScm::Adapters::GitAdapter || super.to_s.blank?
      'master'
    else
      super
    end
  end
end
