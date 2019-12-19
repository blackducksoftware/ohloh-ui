# frozen_string_literal: true

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

  it 'must handle errors in fisbot api during DELETE' do
    VCR.use_cassette('delete_code_location_subscription_failed', match_requests_on: [:path]) do
      lambda do
        CodeLocationSubscription.new(code_location_id: 42, client_relation_id: 100).delete
      end.must_raise(FisbotApiError)
    end
  end

  it 'should send https request and delete subscription for a given code_location' do
    api_key = ENV['FISBOT_CLIENT_REGISTRATION_ID']
    url = URI("https://vcrlocalhost.org:4004/api/v1/subscriptions/264/101.json?api_key=#{api_key}")
    ApiAccess.any_instance.stubs(:resource_uri).returns(url)

    VCR.use_cassette('delete_code_location_subscription', erb: { code_location_id: 263, client_relation_id: 100 }) do
      response_body = CodeLocationSubscription.new(code_location_id: 263, client_relation_id: 100).delete
      response_body.body.must_match 'Subscription Deleted Successfully'
    end
  end
end
