module ScmHelper
  def scm_options_for_select(scm_type)
    options_hash = { CVS: 'cvs', Subversion: 'svn_sync', Git: 'git',
                     Mercurial: 'hg', Bazaar: 'bzr' }

    current_selection = 'svn_sync' if scm_type.to_s == 'svn'
    current_selection ||= scm_type || 'svn_sync'
    options_for_select(options_hash, current_selection.to_s)
  end
end
