# frozen_string_literal: true

require 'test_helper'

class GithubApiTest < ActiveSupport::TestCase
  let(:github_api) { GithubApi.new(code: Faker::Internet.password) }

  it 'must return the correct github login' do
    VCR.use_cassette('GithubVerification') do
      _(github_api.login).must_equal 'notalex'
    end
  end

  it 'must return the correct github email' do
    VCR.use_cassette('GithubVerification') do
      _(github_api.email).must_equal 'alex@example.com'
    end
  end

  it 'must return the correct access token' do
    VCR.use_cassette('GithubVerification') do
      _(github_api.access_token).must_equal 'e068fc1968fakef5c7e7fake6369336fake4bab9'
    end
  end

  it 'all_emails returns secondary_emails plus email' do
    api = GithubApi.new('dummy_code')
    api.stubs(:secondary_emails).returns(['sec1@example.com', 'sec2@example.com'])
    api.stubs(:email).returns('primary@example.com')

    assert_equal ['sec1@example.com', 'sec2@example.com', 'primary@example.com'], api.all_emails
  end

  it 'all_emails returns only email if no secondary_emails' do
    api = GithubApi.new('dummy_code')
    api.stubs(:secondary_emails).returns([])
    api.stubs(:email).returns('primary@example.com')

    assert_equal ['primary@example.com'], api.all_emails
  end
end
