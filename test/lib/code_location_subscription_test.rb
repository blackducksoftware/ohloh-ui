require 'test_helper'

class CodeLocationSubscriptionTest < ActiveSupport::TestCase
  it 'should get the post to fisbot to create subscription for a given code_location' do
    VCR.use_cassette('create_code_location_subscription') do
      response_body = CodeLocationSubscription.new(code_location_id: 263, client_relation_id: 100).save
      response_body.must_equal 'Subscription Added Successfully'
    end
  end

  it 'should get the post to fisbot to delete subscription for a given code_location' do
    VCR.use_cassette('delete_code_location_subscription', erb: { code_location_id: 263, client_relation_id: 100 }) do
      response_body = CodeLocationSubscription.new(code_location_id: 263, client_relation_id: 100).delete
      response_body.body.must_match 'Subscription Deleted Successfully'
    end
  end
end
