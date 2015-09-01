require 'test_helper'

class BzrClumpTest < ActiveSupport::TestCase
  describe 'url' do
    it 'must be aliased to path' do
      code_set_id = Faker::Number.number(2).to_i
      path = ClumpDirectory.path(code_set_id)
      bzr_clump = BzrClump.new(code_set_id: code_set_id)
      bzr_clump.url.must_equal path
    end
  end

  describe 'scm_class' do
    it 'must return BzrlibAdapter' do
      BzrClump.new.scm_class.must_equal(OhlohScm::Adapters::BzrlibAdapter)
    end
  end
end
