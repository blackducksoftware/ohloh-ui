# frozen_string_literal: true

require 'test_helper'

class Forge::GithubTest < ActiveSupport::TestCase
  describe 'match' do
    it 'should return nil for garbage' do
      _(Forge::Github.new.match('I am a banana!')).must_be_nil
    end

    it 'should return nil for random URL' do
      _(Forge::Github.new.match('http://lolcats.com')).must_be_nil
    end

    it 'should accept git url and create a new Forge::Match with the correct initialization parameters' do
      forge = Forge::Github.new
      Forge::Match.expects(:new).with(forge, 'UserName', 'project_name')
      forge.match('git://github.com/UserName/project_name.git')
    end

    it 'should accept http url and create a new Forge::Match with the correct initialization parameters' do
      forge = Forge::Github.new
      Forge::Match.expects(:new).with(forge, 'UserName', 'project_name')
      forge.match('http://github.com/UserName/project_name')
    end

    it 'should accept https url and create a new Forge::Match with the correct initialization parameters' do
      forge = Forge::Github.new
      Forge::Match.expects(:new).with(forge, 'UserName', 'project_name')
      forge.match('https://github.com/UserName/project_name')
    end
  end

  describe 'json_api_url' do
    it 'should return public json key if ENV["GITHUB_AUTH_TOKEN"] is undefined' do
      old_github_auth_token = ENV.delete('GITHUB_AUTH_TOKEN')
      correct_url = 'https://api.github.com/repos/UserName/project_name'
      mock_match = mock
      mock_match.expects(:owner_at_forge).returns('UserName')
      mock_match.expects(:name_at_forge).returns('project_name')
      _(Forge::Github.new.json_api_url(mock_match)).must_equal correct_url
      ENV['GITHUB_AUTH_TOKEN'] = old_github_auth_token
    end

    it 'should return public json key if ENV["GITHUB_AUTH_TOKEN"] is undefined' do
      old_github_auth_token = ENV.delete('GITHUB_AUTH_TOKEN')
      ENV['GITHUB_AUTH_TOKEN'] = 'DEADBEEF'
      correct_url = 'https://api.github.com/repos/UserName/project_name?access_token=DEADBEEF'
      mock_match = mock
      mock_match.expects(:owner_at_forge).returns('UserName')
      mock_match.expects(:name_at_forge).returns('project_name')
      _(Forge::Github.new.json_api_url(mock_match)).must_equal correct_url
      ENV['GITHUB_AUTH_TOKEN'] = old_github_auth_token
    end
  end
end
