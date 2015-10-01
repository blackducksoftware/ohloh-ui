require 'test_helper'

class GithubVerificationTest < ActiveSupport::TestCase
  describe 'generate_access_token' do
    it 'must set auth_id using temporary code' do
      access_token = stub_github_verification
      code = Faker::Internet.password
      github_verification = GithubVerification.create!(code: code)
      github_verification.auth_id.must_equal access_token
    end
  end
end
