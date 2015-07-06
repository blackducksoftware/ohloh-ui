require 'test_helper'

class GitRepositoryTest < ActiveSupport::TestCase
  let(:source_scm_class) { GitRepository.new.source_scm_class }

  before { source_scm_class.any_instance.stubs(:validate_server_connection) }

  it 'must find existing repository by url and branch_name' do
    repository = create(:git_repository, bypass_url_validation: false)

    GitRepository.find_existing(repository).must_equal repository
  end
end
