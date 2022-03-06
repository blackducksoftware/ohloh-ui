# frozen_string_literal: true

require 'test_helper'

class Forge::BitbucketTest < ActiveSupport::TestCase
  describe 'match' do
    it 'should return nil for garbage' do
      _(Forge::Bitbucket.new.match('I am a banana!')).must_be_nil
    end

    it 'should return nil for random URL' do
      _(Forge::Bitbucket.new.match('http://lolcats.com')).must_be_nil
    end

    it 'should accept https url and create a new Forge::Match with the correct initialization parameters' do
      forge = Forge::Bitbucket.new
      Forge::Match.expects(:new).with(forge, 'owner_at_forge', 'name_at_forge')
      forge.match('https://bitbucket.org/owner_at_forge/name_at_forge')
    end

    it 'should accept url with user at and create a new Forge::Match with the correct initialization parameters' do
      forge = Forge::Bitbucket.new
      Forge::Match.expects(:new).with(forge, 'owner_at_forge', 'name_at_forge')
      forge.match('http://owner_at_forge@bitbucket.org/owner_at_forge/name_at_forge')
    end
  end

  describe 'json_api_url' do
    it 'should return correct json metadata url' do
      correct_url = 'https://api.bitbucket.org/1.0/repositories/owner_at_forge/name_at_forge'
      mock_match = mock
      mock_match.expects(:owner_at_forge).returns('owner_at_forge')
      mock_match.expects(:name_at_forge).returns('name_at_forge')
      _(Forge::Bitbucket.new.json_api_url(mock_match)).must_equal correct_url
    end
  end
end
