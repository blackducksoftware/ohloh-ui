require 'test_helper'

describe 'TwitterDigits' do
  let(:service_provider_url) { Faker::Internet.url }
  let(:credentials) { "oauth_consumer_key=#{ Faker::Internet.password }" }

  before do
    original_twitter_digits_path = File.expand_path('../../../../app/lib/twitter_digits.rb', __FILE__)
    load original_twitter_digits_path
  end

  it 'must return the id_str when response is 200' do
    id_str = Faker::Internet.password
    response = stub(code: '200', body: { id_str: id_str }.to_json)
    Net::HTTP.any_instance.stubs(:get2).returns(response)

    TwitterDigits.get_twitter_id(service_provider_url, credentials).must_equal id_str
  end

  it 'must return nil when response is not 200' do
    response = stub(code: '404')
    Net::HTTP.any_instance.stubs(:get2).returns(response)

    TwitterDigits.get_twitter_id(service_provider_url, credentials).must_be_nil
  end
end
