class SvnSyncRepository < SvnRepository
  def english_name
    'Subversion (via SvnSync)'
  end

  class << self
    # svnsync is not universally supported.
    # This method checks the URL against a list of known good forges.
    # If the URL is not on the list, we downgrade to SvnRepository and
    # perform old-fashioned brute-force downloads.
    def get_compatible_class(url)
      [/(svn|http|https):\/\/([a-z0-9_\-]+\.)*svn\.sourceforge\.net\//i,
       /(svn|http|https):\/\/([a-z0-9_\-]+\.)*svn\.code\.sourceforge\.net\/p\//i,
       /(svn|http|https):\/\/([a-z0-9_\-]+\.)*svn\.code\.sf\.net\/p\//i,
       /(svn|http|https):\/\/garage\.maemo\.org\/svn\//i,
       /(svn|http|https):\/\/[a-z0-9_\-]+\.googlecode\.com\/svn\//i].each do |forge|
        return self if url =~ forge
      end

      SvnRepository
    end


    def find_existing(repository)
      SvnSyncRepository.find_by(url: repository.url)
    end
  end
end
