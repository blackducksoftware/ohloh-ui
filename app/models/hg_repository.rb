class HgRepository < Repository
  def source_scm_class
    OhlohScm::Adapters::HglibAdapter
  end

  class << self
    def find_existing(repository)
      HgRepository.where(url: repository.url).first
    end
  end
end
