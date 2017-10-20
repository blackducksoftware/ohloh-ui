require 'test_helper'

class FirebaseVerificationTest < ActiveSupport::TestCase
  describe 'generate_auth_id' do
    it 'must set auth_id using firebase credentials' do
      decoded_val = stub_firebase_verification
      JWT.stubs(:decode).returns(decoded_val)
      VCR.use_cassette('google_keys') do
        firebase_verification = FirebaseVerification.create!(
          credentials: Faker::Internet.password
        )
        firebase_verification.auth_id.must_equal decoded_val[0]['user_id']
      end
    end

    it 'Should add error when decoded token is nil' do
      VCR.use_cassette('google_keys') do
        proc { FirebaseVerification.create!(credentials: '') }.must_raise ActiveRecord::RecordInvalid
      end
    end
  end
end
