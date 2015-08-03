require 'test_helper'

class BzrRepositoryTest < ActiveSupport::TestCase
  let(:source_scm_class) { BzrRepository.new.source_scm_class }

  before { source_scm_class.any_instance.stubs(:validate_server_connection) }

  it 'must find existing repository by url' do
    repository = create(:bzr_repository, bypass_url_validation: false)

    BzrRepository.find_existing(repository).must_equal repository
  end
end
