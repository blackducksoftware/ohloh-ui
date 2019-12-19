# frozen_string_literal: true

require 'test_helper'

class Forge::SourceForgeTest < ActiveSupport::TestCase
  describe 'match' do
    it 'should return nil for garbage' do
      assert_nil Forge::SourceForge.new.match('I am a banana!')
    end

    it 'should return nil for random URL' do
      assert_nil Forge::SourceForge.new.match('http://lolcats.com')
    end

    it 'should accept cvs url and create a new Forge::Match with the correct initialization parameters' do
      forge = Forge::SourceForge.new
      Forge::Match.expects(:new).with(forge, nil, 'project_name')
      forge.match(':pserver:anonymous:@project_name.cvs.sourceforge.net:/cvsroot/project_name')
    end

    it 'should accept svn url and create a new Forge::Match with the correct initialization parameters' do
      forge = Forge::SourceForge.new
      Forge::Match.expects(:new).with(forge, nil, 'project_name')
      forge.match('svn://svn.code.sf.net/p/project_name/svn/trunk')
    end

    it 'should accept hg url and create a new Forge::Match with the correct initialization parameters' do
      forge = Forge::SourceForge.new
      Forge::Match.expects(:new).with(forge, nil, 'project_name')
      forge.match('http://project_name.hg.sourceforge.net/hgweb/project_name/documentation/')
    end

    it 'should accept git url and create a new Forge::Match with the correct initialization parameters' do
      forge = Forge::SourceForge.new
      Forge::Match.expects(:new).with(forge, nil, 'project_name')
      forge.match('git://project_name.git.sourceforge.net/gitroot/project_name')
    end

    it 'should accept bzr url and create a new Forge::Match with the correct initialization parameters' do
      forge = Forge::SourceForge.new
      Forge::Match.expects(:new).with(forge, nil, 'project_name')
      forge.match('bzr://project_name.bzr.sourceforge.net/bzrroot/project_name')
    end

    it 'should accept sf project url and create a new Forge::Match with the correct initialization parameters' do
      forge = Forge::SourceForge.new
      Forge::Match.expects(:new).with(forge, nil, 'project_name')
      forge.match('https://svn.code.sf.net/p/project_name/code/src')
    end

    it 'should accept project url and create a new Forge::Match with the correct initialization parameters' do
      forge = Forge::SourceForge.new
      Forge::Match.expects(:new).with(forge, nil, 'project_name')
      forge.match('http://project_name.sourceforge.net/hg/project_name/')
    end
  end

  describe 'json_api_url' do
    it 'should return correct json metadata url' do
      correct_url = 'http://sourceforge.net/rest/p/name_at_forge/'
      mock_match = mock
      mock_match.expects(:name_at_forge).returns('name_at_forge')
      Forge::SourceForge.new.json_api_url(mock_match).must_equal correct_url
    end
  end
end
