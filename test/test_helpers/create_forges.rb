# frozen_string_literal: true

module CreateForges
  FORGES = [{ name: 'Github', url: 'git://github.com', type: 'Forge::Github' },
            { name: 'Google Code', url: 'http://code.google.com', type: 'Forge::GoogleCode' },
            { name: 'SourceForge', url: 'http://sourceforge.net', type: 'Forge::SourceForge' },
            { name: 'Launchpad', url: 'https://launchpad.net', type: 'Forge::Launchpad' },
            { name: 'Bitbucket', url: 'https://bitbucket.org', type: 'Forge::Bitbucket' },
            { name: 'Codeplex', url: 'http://www.codeplex.com', type: 'Forge::Codeplex' }].freeze

  def create_forges
    FORGES.each do |forge|
      Forge.where(forge).first_or_create
    end
  end
end
