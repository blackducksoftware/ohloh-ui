class SvnRepository < Repository
  after_validation :set_url_and_branch_name

  def source_scm_class
    OhlohScm::Adapters::SvnChainAdapter
  end

  private

  def set_url_and_branch_name
    return if errors.present?

    self.url = source_scm.restrict_url_to_trunk
  end
end
