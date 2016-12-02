require 'test_helper'

class SvnRepositoryTest < ActiveSupport::TestCase
  it 'must return SVN adapter' do
    SvnRepository.new.source_scm_class.must_equal OhlohScm::Adapters::SvnChainAdapter
  end

  it 'must return false for dag?' do
    SvnRepository.dag?.must_equal false
  end
end
