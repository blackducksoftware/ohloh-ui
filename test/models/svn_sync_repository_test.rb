require 'test_helper'

class SvnSyncRepositoryTest < ActiveSupport::TestCase
  let(:source_scm_class) { SvnSyncRepository.new.source_scm_class }

  before do
    source_scm_class.any_instance.stubs(:validate_server_connection)
    source_scm_class.any_instance.stubs(:restrict_url_to_trunk).returns(Faker::Internet.url)
  end

  it 'must find existing repository by url' do
    repository = create(:svn_sync_repository, bypass_url_validation: false)

    SvnSyncRepository.find_existing(repository).must_equal repository
  end

  it 'email_addresses: must be false' do
    SvnSyncRepository.wont_be :email_addresses?
  end

  describe 'get_compatible_class' do
    it 'must return SvnSyncRepository for code.sf urls' do
      url = 'https://svn.code.sf.net/p/foo/code/bar'

      SvnSyncRepository.get_compatible_class(url).must_equal SvnSyncRepository
    end

    it 'must return SvnSyncRepository for sourceforge urls' do
      url = 'https://svn.sourceforge.net/p/foo/code/bar'

      SvnSyncRepository.get_compatible_class(url).must_equal SvnSyncRepository
    end

    it 'must return SvnSyncRepository for maemo urls' do
      url = 'https://garage.maemo.org/svn/p/foo/code/bar'

      SvnSyncRepository.get_compatible_class(url).must_equal SvnSyncRepository
    end

    it 'must return SvnSyncRepository for googlecode urls' do
      url = 'https://foo.googlecode.com/svn/p/foo/code/bar'

      SvnSyncRepository.get_compatible_class(url).must_equal SvnSyncRepository
    end

    it 'must return SvnRepository for other urls' do
      url = Faker::Internet.url

      SvnSyncRepository.get_compatible_class(url).must_equal SvnRepository
    end
  end
end
