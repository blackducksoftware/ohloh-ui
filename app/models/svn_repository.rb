class SvnRepository < Repository
  after_validation :set_url_and_branch_name

  def source_scm_class
    OhlohScm::Adapters::SvnChainAdapter
  end

  def nice_url
    url
  end

  class << self
    def find_existing(repository)
      SvnRepository.find_by(url: repository.url)
    end

    def email_addresses?
      false
    end
  end

  private

  def set_url_and_branch_name
    return if bypass_url_validation || errors.present?

    self.url = source_scm.restrict_url_to_trunk
    self.branch_name = source_scm.branch_name
  end
end
