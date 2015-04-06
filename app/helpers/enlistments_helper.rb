module EnlistmentsHelper
  def options_for_select_type
    options_hash = {
      'Subversion'       => 'SvnSyncRepository',
      'CVS'              => 'CvsRepository',
      'Git'              => 'GitRepository',
      'Mercurial'        => 'HgRepository',
      'Bazaar'           => 'BzrRepository'
    }
    options_for_select(options_hash)
  end
end
