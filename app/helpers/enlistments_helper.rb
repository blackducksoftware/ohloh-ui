module EnlistmentsHelper
  def options_for_select_type(repository)
    current_selection = repository.class.to_s || 'SvnSyncRepository'
    current_selection = 'SvnSyncRepository' if current_selection == 'SvnRepository'

    options_hash = {
      'Subversion'       => 'SvnSyncRepository',
      'CVS'              => 'CvsRepository',
      'Git'              => 'GitRepository',
      'Mercurial'        => 'HgRepository',
      'Bazaar'           => 'BzrRepository',
      'Github Repositories' => 'GithubUser' }

    options_for_select(options_hash, current_selection)
  end
end
