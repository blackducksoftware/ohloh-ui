class SvnRepository < Repository
  after_validation :restrict_url_to_trunk

  def source_scm_class
    OhlohScm::Adapters::SvnChainAdapter
  end

  def nice_url
    url
  end

  private

  def restrict_url_to_trunk
    return if bypass_url_validation || errors.present?

    self.url = source_scm.restrict_url_to_trunk
  end
end
