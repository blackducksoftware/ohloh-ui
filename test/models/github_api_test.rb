require 'test_helper'

class GithubApiTest < ActiveSupport::TestCase
  let(:github_api) { GithubApi.new(code: Faker::Internet.password) }

  it 'must return the correct github login' do
    VCR.use_cassette('GithubVerification') do
      github_api.login.must_equal 'notalex'
    end
  end

  it 'must return the correct github email' do
    VCR.use_cassette('GithubVerification') do
      github_api.email.must_equal 'alex@example.com'
    end
  end

  it 'must return the correct access token' do
    VCR.use_cassette('GithubVerification') do
      github_api.access_token.must_equal 'e068fc1968fakef5c7e7fake6369336fake4bab9'
    end
  end

  describe 'created_at' do
    it 'must correctly parse github account created at string' do
      VCR.use_cassette('GithubVerification') do |cassette|
        github_api.created_at.must_be :<, relative_time(cassette, months: -1)
      end
    end

    it 'must correctly parse created at string when it is newer' do
      VCR.use_cassette('GithubVerificationSpammer') do |cassette|
        github_api.created_at.must_be :>, relative_time(cassette, months: -1)
      end
    end
  end

  describe 'repository_has_language?' do
    it 'must return true if github account has any repository with language' do
      VCR.use_cassette('GithubVerification') do
        github_api.must_be :repository_has_language?
      end
    end

    it 'must return false if github account has no repository with language' do
      VCR.use_cassette('GithubVerificationSpammer') do
        github_api.wont_be :repository_has_language?
      end
    end
  end
end

def relative_time(cassette, months:)
  cassette.originally_recorded_at.advance(months: months)
end
