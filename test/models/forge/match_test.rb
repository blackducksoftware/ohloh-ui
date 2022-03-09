# frozen_string_literal: true

require 'test_helper'

class Forge::MatchTest < ActiveSupport::TestCase
  describe 'first' do
    it 'should return nil for unknown url' do
      _(Forge::Match.first('http://lolcats.com')).must_be_nil
    end

    it 'should return a Forge::Bitbucket for bitbucket url' do
      _(Forge::Match.first('https://bitbucket.org/owner/project').forge.name).must_equal 'Bitbucket'
    end

    it 'should return a Forge::Codeplex for bitbucket url' do
      _(Forge::Match.first('https://project.svn.codeplex.com/svn').forge.name).must_equal 'Codeplex'
    end

    it 'should return a Forge::Github for bitbucket url' do
      _(Forge::Match.first('git://github.com/user/project.git').forge.name).must_equal 'Github'
    end

    it 'should return a Forge::GoogleCode for bitbucket url' do
      _(Forge::Match.first('http://code.google.com/a/organization/p/project/').forge.name).must_equal 'Google Code'
    end

    it 'should return a Forge::Launchpad for bitbucket url' do
      _(Forge::Match.first('https://code.launchpad.net/~organization/project/trunk').forge.name).must_equal 'Launchpad'
    end

    it 'should return a Forge::SourceForge for bitbucket url' do
      _(Forge::Match.first('svn://svn.code.sf.net/p/project/svn/trunk').forge.name).must_equal 'SourceForge'
    end
  end

  describe 'project' do
    it 'should return new Project object for Forge::Bitbucket match' do
      VCR.use_cassette('ForgeMatchBitbucket') do
        project = Forge::Match.first('http://bitbucket.org/durin42/hgsubversion/').project
        _(project.name).must_equal 'hgsubversion'
        _(project.vanity_url).must_equal 'hgsubversion'
        _(project.description).must_match 'hgsubversion is an extension for Mercurial'
        _(project.url).must_equal 'http://groups.google.com/group/hgsubversion/'
      end
    end

    it 'should return new Project object for Forge::Codeplex match' do
      project = Forge::Match.first('https://smextensionlib.svn.codeplex.com/svn').project
      _(project.name).must_be_nil
    end

    it 'should return new Project object for Forge::Github match' do
      VCR.use_cassette('ForgeMatchGithub') do
        project = Forge::Match.first('https://github.com/rails/rails').project
        _(project.name).must_equal 'rails'
        _(project.vanity_url).must_equal 'rails'
        _(project.description).must_match 'Ruby on Rails'
        _(project.url).must_equal 'http://rubyonrails.org'
      end
    end

    it 'should return new Project object for Forge::GoogleCode match' do
      VCR.use_cassette('ForgeMatchGoogleCode') do
        project = Forge::Match.first('https://code.google.com/p/jwysiwyg/').project
        _(project.name).must_equal 'jwysiwyg'
        _(project.vanity_url).must_equal 'jwysiwyg'
        _(project.description).must_match 'WYSIWYG jQuery Plugin'
        _(project.url).must_equal 'http://code.google.com/p/jwysiwyg/'
      end
    end

    it 'should return new Project object for Forge::GoogleCode (organization) match' do
      VCR.use_cassette('ForgeMatchGoogleCodeOrg') do
        project = Forge::Match.first('http://code.google.com/a/apache-extras.org/p/phpmailer/').project
        _(project.name).must_equal 'phpmailer'
        _(project.vanity_url).must_equal 'phpmailer'
        _(project.description).must_match 'PHPMailer is a Full Featured Email'
        _(project.url).must_equal 'http://code.google.com/a/apache-extras.org/p/phpmailer/'
      end
    end

    it 'should return new Project object for Forge::LaunchPad match' do
      VCR.use_cassette('ForgeMatchLaunchPad') do
        project = Forge::Match.first('https://code.launchpad.net/~knny-myer/wagwoord/trunk').project
        _(project.name).must_equal 'A (mnemonic) password generator'
        _(project.vanity_url).must_equal 'wagwoord'
        _(project.description).must_match 'Python password generator'
      end
    end

    it 'should return new Project object for Forge::SourceForge match' do
      VCR.use_cassette('ForgeMatchSourceForge') do
        project = Forge::Match.first('https://jotwiki.svn.sourceforge.net/svnroot/jotwiki/jotwiki/').project
        _(project.name).must_equal 'jotwiki'
        _(project.vanity_url).must_equal 'jotwiki'
        _(project.description).must_match 'a simple but powerful java based WIKI software'
        _(project.url).must_equal 'http://www.jotwiki.net'
      end
    end

    it 'should return new Project object for Forge::SourceForge (cvs) match' do
      VCR.use_cassette('ForgeMatchSourceForgeCVS') do
        project = Forge::Match.first(':pserver:anonymous:@freecaller.cvs.sourceforge.net:/cvsroot/freecaller').project
        _(project.name).must_equal 'FreeCaller'
        _(project.vanity_url).must_equal 'freecaller'
        _(project.description).must_match 'FreeCaller is a Symbian application'
        _(project.url).must_equal 'http://freecaller.wiki.sourceforge.net'
      end
    end
  end

  describe 'code_locations' do
    it 'should return new code_location for Forge::Bitbucket match' do
      match = Forge::Match.first('http://bitbucket.org/durin42/hgsubversion/')
      code_locations = match.code_locations
      _(code_locations.length).must_equal 1
      _(code_locations[0].scm_type).must_equal :hg
      _(code_locations[0].url).must_equal 'https://bitbucket.org/durin42/hgsubversion'
      _(code_locations[0].forge_match).must_equal match
    end

    it 'should return new code_location for Forge::Codeplex match' do
      match = Forge::Match.first('https://smextensionlib.svn.codeplex.com/svn')
      code_locations = match.code_locations
      _(code_locations.length).must_equal 0
    end

    it 'should return new code_location for Forge::Github match' do
      VCR.use_cassette('ForgeMatchGithub') do
        match = Forge::Match.first('https://github.com/rails/rails')
        code_locations = match.code_locations
        _(code_locations.length).must_equal 1
        _(code_locations[0].scm_type).must_equal :git
        _(code_locations[0].url).must_equal 'https://github.com/rails/rails'
        _(code_locations[0].branch).must_equal 'main'
        _(code_locations[0].forge_match).must_equal match
      end
    end

    it 'should return new code_location for Forge::GoogleCode (svn) match' do
      VCR.use_cassette('ForgeMatchGoogleCodeRepository') do
        match = Forge::Match.first('https://code.google.com/p/jwysiwyg/')
        code_locations = match.code_locations
        _(code_locations.length).must_equal 1
        _(code_locations[0].scm_type).must_equal :svn_sync
        _(code_locations[0].url).must_equal 'http://jwysiwyg.googlecode.com/svn/trunk/'
        _(code_locations[0].forge_match).must_equal match
      end
    end

    it 'should return new code_location for Forge::GoogleCode (hg) match' do
      VCR.use_cassette('ForgeMatchGoogleCodeRepositoryHg') do
        match = Forge::Match.first('https://pdd-by.googlecode.com/hg/')
        code_locations = match.code_locations
        _(code_locations.length).must_equal 1
        _(code_locations[0].scm_type).must_equal :hg
        _(code_locations[0].url).must_equal 'https://code.google.com/p/pdd-by/'
        _(code_locations[0].forge_match).must_equal match
      end
    end

    it 'should return new code_location for Forge::GoogleCode (git) match' do
      VCR.use_cassette('ForgeMatchGoogleCodeRepositoryGit') do
        match = Forge::Match.first('http://cryptsetup.googlecode.com/git')
        code_locations = match.code_locations
        _(code_locations.length).must_equal 1
        _(code_locations[0].scm_type).must_equal :git
        _(code_locations[0].url).must_equal 'https://code.google.com/p/cryptsetup/'
        _(code_locations[0].forge_match).must_equal match
      end
    end

    it 'should return new code_location for Forge::LaunchPad match' do
      VCR.use_cassette('ForgeMatchLaunchPadRepository') do
        match = Forge::Match.first('https://code.launchpad.net/~knny-myer/wagwoord/trunk')
        code_locations = match.code_locations
        _(code_locations.length).must_equal 1
        _(code_locations[0].scm_type).must_equal :bzr
        _(code_locations[0].url).must_equal 'lp:wagwoord'
        _(code_locations[0].forge_match).must_equal match
      end
    end

    it 'should return new code_location for Forge::LaunchPad (alt) match' do
      VCR.use_cassette('ForgeMatchLaunchPadRepositoryAlt') do
        match = Forge::Match.first('https://code.launchpad.net/maas/1.5')
        code_locations = match.code_locations
        _(code_locations.length).must_equal 1
        _(code_locations[0].scm_type).must_equal :bzr
        _(code_locations[0].url).must_equal 'lp:maas'
        _(code_locations[0].forge_match).must_equal match
      end
    end

    it 'should return new code_location for Forge::LaunchPad (alt) match' do
      VCR.use_cassette('ForgeMatchLaunchPadRepositoryAlt2') do
        match = Forge::Match.first('http://launchpad.net/ampoule')
        code_locations = match.code_locations
        _(code_locations.length).must_equal 1
        _(code_locations[0].scm_type).must_equal :bzr
        _(code_locations[0].url).must_equal 'lp:ampoule'
        _(code_locations[0].forge_match).must_equal match
      end
    end

    it 'should return new code_location for Forge::SourceForge match' do
      VCR.use_cassette('ForgeMatchSourceForge') do
        match = Forge::Match.first('https://jotwiki.svn.sourceforge.net/svnroot/jotwiki/jotwiki/')
        code_locations = match.code_locations
        _(code_locations.length).must_equal 1
        _(code_locations[0].scm_type).must_equal :svn_sync
        _(code_locations[0].url).must_equal 'svn://svn.code.sf.net/p/jotwiki/code'
        _(code_locations[0].forge_match).must_equal match
      end
    end

    it 'should return new code_location for Forge::SourceForge (cvs) match' do
      VCR.use_cassette('ForgeMatchSourceForgeCVS') do
        match = Forge::Match.first(':pserver:anonymous:@freecaller.cvs.sourceforge.net:/cvsroot/freecaller')
        code_locations = match.code_locations
        _(code_locations.length).must_equal 1
        _(code_locations[0].scm_type).must_equal 'cvs'
        _(code_locations[0].url).must_equal ':pserver:anonymous:@freecaller.cvs.sourceforge.net:/cvsroot/freecaller'
        _(code_locations[0].forge_match).must_equal match
      end
    end
  end

  describe 'to_s' do
    it 'should give nice string for a Forge::Bitbucket match' do
      name = 'Bitbucket:durin42/hgsubversion'
      _(Forge::Match.first('http://bitbucket.org/durin42/hgsubversion/').to_s).must_equal name
    end

    it 'should give nice string for a Forge::Codeplex match' do
      _(Forge::Match.first('https://smextensionlib.svn.codeplex.com/svn').to_s).must_equal 'Codeplex:smextensionlib'
    end

    it 'should give nice string for a Forge::Github match' do
      _(Forge::Match.first('https://github.com/rails/rails').to_s).must_equal 'Github:rails/rails'
    end

    it 'should give nice string for a Forge::GoogleCode match' do
      _(Forge::Match.first('https://code.google.com/p/jwysiwyg/').to_s).must_equal 'Google Code:jwysiwyg'
    end

    it 'should give nice string for a Forge::LaunchPad match' do
      str = 'Launchpad:knny-myer/wagwoord'
      _(Forge::Match.first('https://code.launchpad.net/~knny-myer/wagwoord/trunk').to_s).must_equal str
    end

    it 'should give nice string for a Forge::SourceForge match' do
      str = 'SourceForge:jotwiki'
      _(Forge::Match.first('https://jotwiki.svn.sourceforge.net/svnroot/jotwiki/jotwiki/').to_s).must_equal str
    end
  end
end
