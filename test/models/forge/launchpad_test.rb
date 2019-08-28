# frozen_string_literal: true

require 'test_helper'

class Forge::LaunchpadTest < ActiveSupport::TestCase
  describe 'match' do
    it 'should return nil for garbage' do
      assert_nil Forge::Launchpad.new.match('I am a banana!')
    end

    it 'should return nil for random URL' do
      assert_nil Forge::Launchpad.new.match('http://lolcats.com')
    end

    it 'should accept code url and create a new Forge::Match with the correct initialization parameters' do
      forge = Forge::Launchpad.new
      Forge::Match.expects(:new).with(forge, 'organization', 'project_name')
      forge.match('https://code.launchpad.net/~organization/project_name/trunk')
    end

    it 'should accept bazaar url and create a new Forge::Match with the correct initialization parameters' do
      forge = Forge::Launchpad.new
      Forge::Match.expects(:new).with(forge, 'organization', 'project_name')
      forge.match('https://bazaar.launchpad.net/~organization/project_name/trunk')
    end

    it 'should accept project only url and create a new Forge::Match with the correct initialization parameters' do
      forge = Forge::Launchpad.new
      Forge::Match.expects(:new).with(forge, nil, 'project_name')
      forge.match('https://code.launchpad.net/project_name/trunk')
    end

    it 'should accept lp only string and create a new Forge::Match with the correct initialization parameters' do
      forge = Forge::Launchpad.new
      Forge::Match.expects(:new).with(forge, nil, 'project_name')
      forge.match('lp:project_name')
    end

    it 'should accept launchpad.net/project and create a new Forge::Match with the correct initialization parameters' do
      forge = Forge::Launchpad.new
      Forge::Match.expects(:new).with(forge, nil, 'project_name')
      forge.match('https://launchpad.net/project_name')
    end
  end

  describe 'json_api_url' do
    it 'should return correct json metadata url' do
      correct_url = 'https://api.launchpad.net/1.0/name_at_forge'
      mock_match = mock
      mock_match.expects(:name_at_forge).returns('name_at_forge')
      Forge::Launchpad.new.json_api_url(mock_match).must_equal correct_url
    end
  end
end
