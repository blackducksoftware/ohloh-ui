class BzrRepository < Repository
  def source_scm_class
    OhlohScm::Adapters::BzrlibAdapter
  end

  class << self
    def find_existing(repository)
      BzrRepository.where(url: repository.url).first
    end
  end
end
