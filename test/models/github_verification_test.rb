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

  it 'wont allow reusing verification from spam account' do
    account = create(:account)
    account.access.spam!

    verification = build(:github_verification, auth_id: account.github_verification.auth_id)
    new_account = build(:account, github_verification: verification)

    new_account.wont_be :valid?
    new_account.errors.messages[:'github_verification.auth_id'].must_be :present?
  end
end
