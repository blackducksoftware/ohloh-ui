require 'test_helper'

class SvnClumpTest < ActiveSupport::TestCase
  it 'must return SvnChainAdapter for scm_class' do
    SvnClump.new.scm_class.must_equal OhlohScm::Adapters::SvnChainAdapter
  end

  it 'url: it must return the corrent path pattern' do
    code_set = create(:code_set)
    svn_clump = SvnClump.new(code_set: code_set)
    svn_clump.url.must_equal "file://#{ svn_clump.path }"
  end
end
