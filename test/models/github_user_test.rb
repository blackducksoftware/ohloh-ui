# frozen_string_literal: true

require 'test_helper'

class GithubUserTest < ActiveSupport::TestCase
  it 'must use url as username' do
    github_user = GithubUser.new(url: 'stan')
    _(github_user.username).must_equal 'stan'
  end

  describe 'valid?' do
    it 'wont be valid for invalid username' do
      username = 'github.com/stan'
      github_user = GithubUser.new(url: username)
      _(github_user).wont_be :valid?
      _(github_user.errors.messages[:url].first).must_equal I18n.t('invalid_github_username')
    end

    it 'wont be valid when username does not exist on github' do
      username = 'invalid_github'
      output = { message: 'Not Found', documentation_url: 'https://developer.github.com/v3' }.to_json
      Open3.stubs(:popen3).returns [nil, stub(read: output)]
      github_user = GithubUser.new(url: username)
      github_user.valid?
      _(github_user.errors.messages[:url].first).must_equal I18n.t('invalid_github_username')
    end

    it 'must avoid duplicate error messages for url' do
      username = 'github.com/stan'
      github_user = GithubUser.new(url: username)
      _(github_user).wont_be :valid?
      _(github_user.errors.messages[:url].count).must_equal 1
    end
  end

  describe 'save!' do
    it 'must create code_locations from given username' do
      VCR.use_cassette('github_repositories') do
        @github_user = GithubUser.new(url: 'renamed')
        # 4 out of 9 repos in the recorded response have `"fork": true`.
        CodeLocation.expects(:create).times(5)
        @github_user.save!
      end
    end

    it 'must create subscription from given code location' do
      @github_user = GithubUser.new(url: 'renamed')
      @proj = create(:project, deleted: false)
      WebMocker.get_code_location
      CodeLocationSubscription.expects(:create).never
      WebMocker.create_subscriptions_for_code_locations
    end
  end

  describe 'attributes' do
    it 'attributes returns url and scm_type' do
      user = GithubUser.new(url: 'octocat')
      expected = { url: 'octocat', scm_type: 'GithubUser' }
      assert_equal expected, user.attributes
    end

    it 'attributes uses alias username for url' do
      user = GithubUser.new(url: 'testuser')
      assert_equal user.url, user.attributes[:url]
      assert_equal 'GithubUser', user.attributes[:scm_type]
    end
  end
end
