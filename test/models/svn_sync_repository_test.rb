require 'test_helper'

class SvnSyncRepositoryTest < ActiveSupport::TestCase
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
