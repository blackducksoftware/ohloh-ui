require 'test_helper'

class HgRepositoryTest < ActiveSupport::TestCase
  let(:source_scm_class) { HgRepository.new.source_scm_class }

  before { source_scm_class.any_instance.stubs(:validate_server_connection) }

  it 'must find existing repository by url' do
    repository = create(:hg_repository, bypass_url_validation: false)

    HgRepository.find_existing(repository).must_equal repository
  end

  it 'must return true for dag' do
    HgRepository.must_be :dag?
  end
end
