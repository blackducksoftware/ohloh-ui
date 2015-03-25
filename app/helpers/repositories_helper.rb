module RepositoriesHelper
  def repository_options_for_select(repository)
    current_selection = repository.class.to_s || 'SvnSyncRepository'
    current_selection = 'SvnSyncRepository' if current_selection == 'SvnRepository'

    options_hash = { CVS: 'CvsRepository', Subversion: 'SvnSyncRepository', Git: 'GitRepository',
                     Mercurial: 'HgRepository', Bazaar: 'BzrRepository' }
    options_for_select(options_hash, current_selection)
  end
end
