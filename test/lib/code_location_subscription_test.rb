require 'test_helper'

class CodeLocationSubscriptionTest < ActiveSupport::TestCase
  it 'should get the post to fisbot to create subscription for a given code_location' do
    VCR.use_cassette('create_code_location_subscription') do
      api = CodeLocationSubscription.new('263').create
      api.body.must_equal 'Subscription Added Successfully'
    end
  end

  it 'should get the post to fisbot to delete subscription for a given code_location' do
    VCR.use_cassette('delete_code_location_subscription') do
      api = CodeLocationSubscription.new('263').delete
      api.body.must_equal 'Subscription Deleted Successfully'
    end
  end
end
