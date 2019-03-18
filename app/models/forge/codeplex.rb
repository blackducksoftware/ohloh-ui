class Forge::Codeplex < Forge
  def match(url)
    return nil if url.blank? || url !~ /codeplex.com/
    return unless (url =~ /\/\/(.+).svn\.codeplex.com\/svn/) ||
                  (url =~ /\/\/hg.*\.codeplex.com\/(.+)/) || (url =~ /\/\/git01\.codeplex.com\/(.+)/)

    Forge::Match.new(self, nil, $1)
  end
end
