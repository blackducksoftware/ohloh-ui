require 'test_helper'

class TwitterDigitsVerificationTest < ActiveSupport::TestCase
  describe 'generate_auth_id' do
    it 'must set auth_id using digits credentials' do
      digits_id = stub_twitter_digits_verification

      digits_verification = TwitterDigitsVerification.create!(
        service_provider_url: Faker::Internet.url, credentials: Faker::Internet.password
      )
      digits_verification.auth_id.must_equal digits_id
    end
  end
end
