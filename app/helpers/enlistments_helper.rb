module EnlistmentsHelper
  def options_for_select_type(repository)
    current_selection = repository.class.to_s || 'SvnSyncRepository'
    current_selection = 'SvnSyncRepository' if current_selection == 'SvnRepository'
    options_hash = { 'Subversion'       => 'SvnSyncRepository',
                     'CVS'              => 'CvsRepository',
                     'Git'              => 'GitRepository',
                     'Mercurial'        => 'HgRepository',
                     'Bazaar'           => 'BzrRepository',
                     'Github Repositories' => 'GithubUser' }
    options_for_select(options_hash, current_selection)
  end

  def enlistment_branch_name_html_snippet(enlistment)
    return unless enlistment.repository.prime_code_location
    content_tag :span, "Branch: #{enlistment.repository.prime_code_location.branch_name}",
                class: 'edit_enlist_branch_name'
  end
end
