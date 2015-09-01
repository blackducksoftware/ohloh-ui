class CvsRepository < Repository
  def source_scm_class
    OhlohScm::Adapters::CvsAdapter
  end

  def nice_url
    [url, module_name].join(' ')
  end

  def normalize_scm_attributes
    super
    self.module_name = source_scm.module_name
  end

  class << self
    def find_existing(repository)
      CvsRepository.find_by(url: repository.url, module_name: repository.module_name)
    end

    def email_addresses?
      false
    end
  end
end
