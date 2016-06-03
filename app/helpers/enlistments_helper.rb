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
    if enlistment.repository.branch_name?
      content_tag :span, "Branch: #{enlistment.repository.branch_name}", class: 'edit_enlist_branch_name'
    elsif enlistment.repository.module_name?
      content_tag :span, "Module: #{enlistment.repository.module_name}", class: 'edit_enlist_module_name'
    end
  end
end
