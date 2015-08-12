require 'test_helper'

class CvsRepositoryTest < ActiveSupport::TestCase
  let(:source_scm_class) { CvsRepository.new.source_scm_class }

  before { CvsRepository.any_instance.stubs(:bypass_url_validation) }
  before { source_scm_class.any_instance.stubs(:validate_server_connection) }

  it 'must find existing repository by url and module_name' do
    repository = create(:cvs_repository)

    CvsRepository.find_existing(repository).must_equal repository
  end

  it 'must return the url plus module_name as nice_url' do
    repository = create(:cvs_repository)

    repository.nice_url.must_equal "#{ repository.url } #{ repository.module_name }"
  end

  it 'email_addresses: must be false' do
    CvsRepository.wont_be :email_addresses?
  end

  describe 'normalize_scm_attributes' do
    it 'must set the module_name correctly' do
      module_name = 'master'
      repository = create(:cvs_repository, module_name: module_name, bypass_url_validation: false)
      repository.module_name.must_equal module_name
    end
  end
end
