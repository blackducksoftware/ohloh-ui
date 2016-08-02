require 'test_helper'

class GitRepositoryTest < ActiveSupport::TestCase
  it 'must find existing repository by url and branch_name' do
    repository = create(:git_repository)

    repository.source_scm_class.must_equal OhlohScm::Adapters::GitAdapter
  end

  it 'must return true for dag?' do
    GitRepository.dag?.must_equal true
  end
end
