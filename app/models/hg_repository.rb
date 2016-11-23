class HgRepository < Repository
  def source_scm_class
    OhlohScm::Adapters::HglibAdapter
  end

  class << self
    def dag?
      true
    end
  end
end
