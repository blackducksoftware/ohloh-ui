class BzrRepository < Repository
  def source_scm_class
    OhlohScm::Adapters::BzrlibAdapter
  end

  class << self
    def dag?
      true
    end
  end
end
