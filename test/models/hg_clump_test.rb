require 'test_helper'

class HgClumpTest < ActiveSupport::TestCase
  it 'must return HglibAdapter for scm_class' do
    HgClump.new.scm_class.must_equal OhlohScm::Adapters::HglibAdapter
  end
end
