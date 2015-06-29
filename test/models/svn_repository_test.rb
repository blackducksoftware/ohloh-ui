require 'test_helper'

class SvnRepositoryTest < ActiveSupport::TestCase
  let(:source_scm_class) { SvnRepository.new.source_scm_class }

  before do
    source_scm_class.any_instance.stubs(:validate_server_connection)
    source_scm_class.any_instance.stubs(:restrict_url_to_trunk).returns(Faker::Internet.url)
  end

  it 'must return the url for nice_url' do
    url = Faker::Internet.url
    SvnRepository.new(url: url).nice_url.must_equal url
  end

  it 'must find existing repository by url' do
    repository = create(:svn_repository, bypass_url_validation: false)

    SvnRepository.find_existing(repository).must_equal repository
  end
end
