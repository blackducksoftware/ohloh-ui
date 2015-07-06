class BzrRepository < Repository
  def source_scm_class
    OhlohScm::Adapters::BzrlibAdapter
  end

  class << self
    def find_existing(repository)
      BzrRepository.find_by(url: repository.url)
    end
  end
end
