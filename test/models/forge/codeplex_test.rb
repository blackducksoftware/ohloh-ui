# frozen_string_literal: true

require 'test_helper'

class Forge::CodeplexTest < ActiveSupport::TestCase
  describe 'match' do
    it 'should return nil for garbage' do
      _(Forge::Codeplex.new.match('I am a banana!')).must_be_nil
    end

    it 'should return nil for random URL' do
      _(Forge::Codeplex.new.match('http://lolcats.com')).must_be_nil
    end

    it 'should accept svn url and create a new Forge::Match with the correct initialization parameters' do
      forge = Forge::Codeplex.new
      Forge::Match.expects(:new).with(forge, nil, 'project_name')
      forge.match('https://project_name.svn.codeplex.com/svn')
    end

    it 'should accept hg url and create a new Forge::Match with the correct initialization parameters' do
      forge = Forge::Codeplex.new
      Forge::Match.expects(:new).with(forge, nil, 'project_name')
      forge.match('https://hg.codeplex.com/project_name')
    end

    it 'should accept git url and create a new Forge::Match with the correct initialization parameters' do
      forge = Forge::Codeplex.new
      Forge::Match.expects(:new).with(forge, nil, 'project_name')
      forge.match('https://git01.codeplex.com/project_name')
    end
  end

  describe 'json_api_url' do
    it 'does not have a json metadata url' do
      _(Forge::Codeplex.new.json_api_url(mock)).must_be_nil
    end
  end
end
