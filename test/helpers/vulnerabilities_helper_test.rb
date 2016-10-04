require 'test_helper'

class VulnerabilitiesHelperTest < ActionView::TestCase
  include VulnerabilitiesHelper

  describe 'major releases' do
    it 'should correctly filter version releases' do
      FactoryGirl.create_list(:major_release_one, 10)
      FactoryGirl.create_list(:major_release_two, 10)
      FactoryGirl.create_list(:major_release_three, 10)
      FactoryGirl.create(:release, version: '10.1')
      FactoryGirl.create(:release, version: '21.1')
      FactoryGirl.create(:release, version: '32.1')
      major_releases(Release.all).must_equal [1, 2, 3, 10, 21, 32]
    end
  end
end
