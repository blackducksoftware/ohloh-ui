# frozen_string_literal: true

require 'test_helper'

class SiteFeaturesHelperTest < ActionView::TestCase
  include SiteFeaturesHelper

  before do
    @project = create(:project)
  end

  describe 'features_hash' do
    it 'should return a hash' do
      _(features_hash).wont_be_empty
      _(features_hash.class).must_equal Hash
    end
  end

  describe 'random_site_features' do
    it 'should return a set of four random features' do
      _(random_site_features.length).must_equal 4
    end
  end
end
