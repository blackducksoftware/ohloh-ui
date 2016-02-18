require 'test_helper'

describe Forge::Github do
  describe 'match' do
    it 'should return nil for garbage' do
      Forge::Github.new.match('I am a banana!').must_equal nil
    end

    it 'should return nil for random URL' do
      Forge::Github.new.match('http://lolcats.com').must_equal nil
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
      Forge::Github.new.json_api_url(mock_match).must_equal correct_url
      ENV['GITHUB_AUTH_TOKEN'] = old_github_auth_token
    end

    it 'should return public json key if ENV["GITHUB_AUTH_TOKEN"] is undefined' do
      old_github_auth_token = ENV.delete('GITHUB_AUTH_TOKEN')
      ENV['GITHUB_AUTH_TOKEN'] = 'DEADBEEF'
      correct_url = 'https://api.github.com/repos/UserName/project_name?access_token=DEADBEEF'
      mock_match = mock
      mock_match.expects(:owner_at_forge).returns('UserName')
      mock_match.expects(:name_at_forge).returns('project_name')
      Forge::Github.new.json_api_url(mock_match).must_equal correct_url
      ENV['GITHUB_AUTH_TOKEN'] = old_github_auth_token
    end
  end

  describe 'get attribute methods' do
    URL = 'git://github.com/rails/rails.git'
    let(:github) { Forge::Github.new }
    let(:match) { github.match(URL) }

    it 'should have all the project attributes' do
      VCR.use_cassette('ForgeMatchGithub') do
        pa = github.get_project_attributes(match)
        pa.keys.sort.must_equal [:name, :vanity_url, :description, :url].sort
        pa[:name].must_equal 'rails'
        pa[:vanity_url].must_equal 'rails'
        pa[:description].must_equal 'Ruby on Rails'
        pa[:url].must_equal 'http://rubyonrails.org'
      end
    end

    it 'should have all the repository attributes' do
      VCR.use_cassette('ForgeMatchGithub') do
        ra = github.get_repository_attributes(match)[0] # return is an array of 1 element
        ra.keys.sort.must_equal [:type, :forge_match, :branch_name, :url].sort
        ra[:type].must_equal GitRepository
        ra[:forge_match].must_be_instance_of Forge::Match
        ra[:branch_name].must_equal nil
        ra[:url].must_equal URL
      end
    end
  end
end
