require 'test_helper'

class GithubVerificationTest < ActiveSupport::TestCase
  describe 'generate_access_token' do
    it 'must set auth_id using temporary code' do
      VCR.use_cassette('GithubVerification') do
        GithubVerification.any_instance.unstub(:generate_access_token)
        github_verification = GithubVerification.create!(code: Faker::Internet.password)
        github_verification.auth_id.must_equal 'notalex'
      end
    end
  end
end
