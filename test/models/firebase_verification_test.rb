# frozen_string_literal: true

require 'test_helper'

class FirebaseVerificationTest < ActiveSupport::TestCase
  describe 'generate_token' do
    it 'must set token using firebase credentials' do
      decoded_val = stub_firebase_verification
      JWT.stubs(:decode).returns(decoded_val)
      VCR.use_cassette('google_keys') do
        firebase_verification = FirebaseVerification.create!(
          credentials: Faker::Internet.password
        )
        _(firebase_verification.token).must_equal decoded_val[0]['user_id']
      end
    end

    it 'Should add error when decoded token is nil' do
      VCR.use_cassette('google_keys') do
        _(proc { FirebaseVerification.create!(credentials: '') }).must_raise ActiveRecord::RecordInvalid
      end
    end
  end

  it 'must raise appropriate error for uniqueness' do
    FirebaseVerification.any_instance.stubs(:generate_token)
    verification = create(:firebase_verification)
    new_verification = build(:firebase_verification, unique_id: verification.unique_id)

    _(new_verification).wont_be :valid?
    message = I18n.t('activerecord.errors.models.firebase_verification.attributes.unique_id.taken')
    _(new_verification.errors.messages[:unique_id].first).must_equal message
  end

  it 'wont report uniqueness message for blank values' do
    FirebaseVerification.any_instance.stubs(:generate_token)
    verification = build(:firebase_verification, unique_id: nil, token: nil)
    _(verification).wont_be :valid?
    _(verification.errors.messages[:unique_id]).must_equal ["can't be blank"]
  end
end
