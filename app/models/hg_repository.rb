class HgRepository < Repository
  def source_scm_class
    OhlohScm::Adapters::HglibAdapter
  end

  class << self
    def find_existing(repository)
      HgRepository.find_by(url: repository.url)
    end

    def dag?
      true
    end
  end
end
