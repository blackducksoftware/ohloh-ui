require 'test_helper'

class Forge::MatchTest < ActiveSupport::TestCase
  describe 'first' do
    it 'should return nil for unknown url' do
      Forge::Match.first('http://lolcats.com').must_equal nil
    end

    it 'should return a Forge::Bitbucket for bitbucket url' do
      Forge::Match.first('https://bitbucket.org/owner/project').forge.name.must_equal 'Bitbucket'
    end

    it 'should return a Forge::Codeplex for bitbucket url' do
      Forge::Match.first('https://project.svn.codeplex.com/svn').forge.name.must_equal 'Codeplex'
    end

    it 'should return a Forge::Github for bitbucket url' do
      Forge::Match.first('git://github.com/user/project.git').forge.name.must_equal 'Github'
    end

    it 'should return a Forge::GoogleCode for bitbucket url' do
      Forge::Match.first('http://code.google.com/a/organization/p/project/').forge.name.must_equal 'Google Code'
    end

    it 'should return a Forge::Launchpad for bitbucket url' do
      Forge::Match.first('https://code.launchpad.net/~organization/project/trunk').forge.name.must_equal 'Launchpad'
    end

    it 'should return a Forge::SourceForge for bitbucket url' do
      Forge::Match.first('svn://svn.code.sf.net/p/project/svn/trunk').forge.name.must_equal 'SourceForge'
    end
  end

  describe 'project' do
    it 'should return new Project object for Forge::Bitbucket match' do
      VCR.use_cassette('ForgeMatchBitbucket') do
        project = Forge::Match.first('http://bitbucket.org/durin42/hgsubversion/').project
        project.name.must_equal 'hgsubversion'
        project.vanity_url.must_equal 'hgsubversion'
        project.description.must_match 'hgsubversion is an extension for Mercurial'
        project.url.must_equal 'http://groups.google.com/group/hgsubversion/'
      end
    end

    it 'should return new Project object for Forge::Codeplex match' do
      project = Forge::Match.first('https://smextensionlib.svn.codeplex.com/svn').project
      project.name.must_equal nil
    end

    it 'should return new Project object for Forge::Github match' do
      VCR.use_cassette('ForgeMatchGithub') do
        project = Forge::Match.first('https://github.com/rails/rails').project
        project.name.must_equal 'rails'
        project.vanity_url.must_equal 'rails'
        project.description.must_match 'Ruby on Rails'
        project.url.must_equal 'http://rubyonrails.org'
      end
    end

    it 'should return new Project object for Forge::GoogleCode match' do
      VCR.use_cassette('ForgeMatchGoogleCode') do
        project = Forge::Match.first('https://code.google.com/p/jwysiwyg/').project
        project.name.must_equal 'jwysiwyg'
        project.vanity_url.must_equal 'jwysiwyg'
        project.description.must_match 'WYSIWYG jQuery Plugin'
        project.url.must_equal 'http://code.google.com/p/jwysiwyg/'
      end
    end

    it 'should return new Project object for Forge::GoogleCode (organization) match' do
      VCR.use_cassette('ForgeMatchGoogleCodeOrg') do
        project = Forge::Match.first('http://code.google.com/a/apache-extras.org/p/phpmailer/').project
        project.name.must_equal 'phpmailer'
        project.vanity_url.must_equal 'phpmailer'
        project.description.must_match 'PHPMailer is a Full Featured Email'
        project.url.must_equal 'http://code.google.com/a/apache-extras.org/p/phpmailer/'
      end
    end

    it 'should return new Project object for Forge::LaunchPad match' do
      VCR.use_cassette('ForgeMatchLaunchPad') do
        project = Forge::Match.first('https://code.launchpad.net/~knny-myer/wagwoord/trunk').project
        project.name.must_equal 'A (mnemonic) password generator'
        project.vanity_url.must_equal 'wagwoord'
        project.description.must_match 'Python password generator'
      end
    end

    it 'should return new Project object for Forge::SourceForge match' do
      VCR.use_cassette('ForgeMatchSourceForge') do
        project = Forge::Match.first('https://jotwiki.svn.sourceforge.net/svnroot/jotwiki/jotwiki/').project
        project.name.must_equal 'jotwiki'
        project.vanity_url.must_equal 'jotwiki'
        project.description.must_match 'a simple but powerful java based WIKI software'
        project.url.must_equal 'http://www.jotwiki.net'
      end
    end

    it 'should return new Project object for Forge::SourceForge (cvs) match' do
      VCR.use_cassette('ForgeMatchSourceForgeCVS') do
        project = Forge::Match.first(':pserver:anonymous:@freecaller.cvs.sourceforge.net:/cvsroot/freecaller').project
        project.name.must_equal 'FreeCaller'
        project.vanity_url.must_equal 'freecaller'
        project.description.must_match 'FreeCaller is a Symbian application'
        project.url.must_equal 'http://freecaller.wiki.sourceforge.net'
      end
    end
  end

  describe 'repositories' do
    it 'should return new repository for Forge::Bitbucket match' do
      match = Forge::Match.first('http://bitbucket.org/durin42/hgsubversion/')
      repositories = match.repositories
      repositories.length.must_equal 1
      repositories[0].is_a?(HgRepository).must_equal true
      repositories[0].url.must_equal 'https://bitbucket.org/durin42/hgsubversion'
      repositories[0].forge_match.must_equal match
    end

    it 'should return new repository for Forge::Codeplex match' do
      match = Forge::Match.first('https://smextensionlib.svn.codeplex.com/svn')
      repositories = match.repositories
      repositories.length.must_equal 0
    end

    it 'should return new repository for Forge::Github match' do
      VCR.use_cassette('ForgeMatchGithub') do
        match = Forge::Match.first('https://github.com/rails/rails')
        repositories = match.repositories
        repositories.length.must_equal 1
        repositories[0].is_a?(GitRepository).must_equal true
        repositories[0].url.must_equal 'git://github.com/rails/rails.git'
        repositories[0].branch_name.must_equal nil
        repositories[0].forge_match.must_equal match
      end
    end

    it 'should return new repository for Forge::GoogleCode (svn) match' do
      VCR.use_cassette('ForgeMatchGoogleCodeRepository') do
        match = Forge::Match.first('https://code.google.com/p/jwysiwyg/')
        repositories = match.repositories
        repositories.length.must_equal 1
        repositories[0].is_a?(SvnRepository).must_equal true
        repositories[0].url.must_equal 'http://jwysiwyg.googlecode.com/svn/trunk/'
        repositories[0].forge_match.must_equal match
      end
    end

    it 'should return new repository for Forge::GoogleCode (hg) match' do
      VCR.use_cassette('ForgeMatchGoogleCodeRepositoryHg') do
        match = Forge::Match.first('https://pdd-by.googlecode.com/hg/')
        repositories = match.repositories
        repositories.length.must_equal 1
        repositories[0].is_a?(HgRepository).must_equal true
        repositories[0].url.must_equal 'https://code.google.com/p/pdd-by/'
        repositories[0].forge_match.must_equal match
      end
    end

    it 'should return new repository for Forge::GoogleCode (git) match' do
      VCR.use_cassette('ForgeMatchGoogleCodeRepositoryGit') do
        match = Forge::Match.first('http://cryptsetup.googlecode.com/git')
        repositories = match.repositories
        repositories.length.must_equal 1
        repositories[0].is_a?(GitRepository).must_equal true
        repositories[0].url.must_equal 'https://code.google.com/p/cryptsetup/'
        repositories[0].forge_match.must_equal match
      end
    end

    it 'should return new repository for Forge::LaunchPad match' do
      VCR.use_cassette('ForgeMatchLaunchPadRepository') do
        match = Forge::Match.first('https://code.launchpad.net/~knny-myer/wagwoord/trunk')
        repositories = match.repositories
        repositories.length.must_equal 1
        repositories[0].is_a?(BzrRepository).must_equal true
        repositories[0].url.must_equal 'lp:wagwoord'
        repositories[0].forge_match.must_equal match
      end
    end

    it 'should return new repository for Forge::LaunchPad (alt) match' do
      VCR.use_cassette('ForgeMatchLaunchPadRepositoryAlt') do
        match = Forge::Match.first('https://code.launchpad.net/maas/1.5')
        repositories = match.repositories
        repositories.length.must_equal 1
        repositories[0].is_a?(BzrRepository).must_equal true
        repositories[0].url.must_equal 'lp:maas'
        repositories[0].forge_match.must_equal match
      end
    end

    it 'should return new repository for Forge::LaunchPad (alt) match' do
      VCR.use_cassette('ForgeMatchLaunchPadRepositoryAlt2') do
        match = Forge::Match.first('http://launchpad.net/ampoule')
        repositories = match.repositories
        repositories.length.must_equal 1
        repositories[0].is_a?(BzrRepository).must_equal true
        repositories[0].url.must_equal 'lp:ampoule'
        repositories[0].forge_match.must_equal match
      end
    end

    it 'should return new repository for Forge::SourceForge match' do
      VCR.use_cassette('ForgeMatchSourceForge') do
        match = Forge::Match.first('https://jotwiki.svn.sourceforge.net/svnroot/jotwiki/jotwiki/')
        repositories = match.repositories
        repositories.length.must_equal 1
        repositories[0].is_a?(SvnRepository).must_equal true
        repositories[0].url.must_equal 'svn://svn.code.sf.net/p/jotwiki/code'
        repositories[0].forge_match.must_equal match
      end
    end

    it 'should return new repository for Forge::SourceForge (cvs) match' do
      VCR.use_cassette('ForgeMatchSourceForgeCVS') do
        match = Forge::Match.first(':pserver:anonymous:@freecaller.cvs.sourceforge.net:/cvsroot/freecaller')
        repositories = match.repositories
        repositories.length.must_equal 1
        repositories[0].is_a?(CvsRepository).must_equal true
        repositories[0].url.must_equal ':pserver:anonymous:@freecaller.cvs.sourceforge.net:/cvsroot/freecaller'
        repositories[0].forge_match.must_equal match
      end
    end
  end

  describe 'to_s' do
    it 'should give nice string for a Forge::Bitbucket match' do
      Forge::Match.first('http://bitbucket.org/durin42/hgsubversion/').to_s.must_equal 'Bitbucket:durin42/hgsubversion'
    end

    it 'should give nice string for a Forge::Codeplex match' do
      Forge::Match.first('https://smextensionlib.svn.codeplex.com/svn').to_s.must_equal 'Codeplex:smextensionlib'
    end

    it 'should give nice string for a Forge::Github match' do
      Forge::Match.first('https://github.com/rails/rails').to_s.must_equal 'Github:rails/rails'
    end

    it 'should give nice string for a Forge::GoogleCode match' do
      Forge::Match.first('https://code.google.com/p/jwysiwyg/').to_s.must_equal 'Google Code:jwysiwyg'
    end

    it 'should give nice string for a Forge::LaunchPad match' do
      str = 'Launchpad:knny-myer/wagwoord'
      Forge::Match.first('https://code.launchpad.net/~knny-myer/wagwoord/trunk').to_s.must_equal str
    end

    it 'should give nice string for a Forge::SourceForge match' do
      str = 'SourceForge:jotwiki'
      Forge::Match.first('https://jotwiki.svn.sourceforge.net/svnroot/jotwiki/jotwiki/').to_s.must_equal str
    end
  end
end
