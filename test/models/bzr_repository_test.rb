require 'test_helper'

class BzrRepositoryTest < ActiveSupport::TestCase
  it 'must find existing repository by url' do
    repository = create(:bzr_repository)
    repository.source_scm_class.must_equal OhlohScm::Adapters::BzrlibAdapter
  end

  it 'must return true for dag?' do
    BzrRepository.dag?.must_equal true
  end
end
