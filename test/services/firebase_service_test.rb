# frozen_string_literal: true

require 'test_helper'

class FirebaseServiceTest < ActiveSupport::TestCase
  describe 'service' do
    it 'decode should give correct token' do
      firebase = FirebaseService.new('fir-sample-8bb3e')
      id_token = 'dfhhdfgyudsgfyugdudygsdu'
      decoded_val = stub_firebase_verification
      JWT.stubs(:decode).returns(decoded_val)
      VCR.use_cassette('google_keys') do
        token = firebase.decode(id_token)
        _(token).must_equal decoded_val
      end
    end

    it 'should return nil for invalid kid' do
      firebase = FirebaseService.new('fir-sample-8bb3e')
      id_token = 'dfhhdfgyudsgfyugdudygsdu'
      decoded_val = stub_firebase_verification('123', 'RS256', ' ')
      JWT.stubs(:decode).returns(decoded_val)
      VCR.use_cassette('google_keys') do
        token = firebase.decode(id_token)
        _(token).must_be_nil
      end
    end

    it 'should return nil for invalid algorithm' do
      firebase = FirebaseService.new('fir-sample-8bb3e')
      id_token = 'dfhhdfgyudsgfyugdudygsdu'
      decoded_val = stub_firebase_verification('123', 'invalid_alg')
      JWT.stubs(:decode).returns(decoded_val)
      VCR.use_cassette('google_keys') do
        token = firebase.decode(id_token)
        _(token).must_be_nil
      end
    end

    it 'should return nil for invalid sub' do
      firebase = FirebaseService.new('fir-sample-8bb3e')
      id_token = 'dfhhdfgyudsgfyugdudygsdu'
      decoded_val = stub_firebase_verification('')
      JWT.stubs(:decode).returns(decoded_val)
      VCR.use_cassette('google_keys') do
        token = firebase.decode(id_token)
        _(token).must_be_nil
      end
    end
  end
end
