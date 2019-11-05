# frozen_string_literal: true

require 'test_helper'

class SiteFeaturesHelperTest < ActionView::TestCase
  include SiteFeaturesHelper

  before do
    @project = create(:project)
  end

  describe 'features_hash' do
    it 'should return a hash' do
      features_hash(@project).wont_be_empty
      features_hash(@project).class.must_equal Hash
    end
  end

  describe 'random_site_features' do
    it 'should return a set of four random features' do
      random_site_features(@project).length.must_equal 4
    end
  end
end
