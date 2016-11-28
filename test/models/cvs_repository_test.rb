require 'test_helper'

class CvsRepositoryTest < ActiveSupport::TestCase
  it 'must return CVS adapter' do
    repository = create(:cvs_repository)

    repository.source_scm_class.must_equal OhlohScm::Adapters::CvsAdapter
  end

  it 'must return the url plus module_name as nice_url' do
    repository = create(:cvs_repository)
    code_location = create(:code_location, repository: repository)

    code_location.nice_url.must_equal "#{repository.url} #{code_location.module_branch_name}"
  end

  describe 'normalize_scm_attributes' do
    it 'must set the module_name correctly' do
      module_name = Faker::Lorem.word
      code_location = create(:code_location, :validate, module_branch_name: module_name)
      code_location.module_branch_name.must_equal module_name
    end
  end
end
