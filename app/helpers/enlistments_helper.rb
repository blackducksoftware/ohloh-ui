module EnlistmentsHelper
  def options_for_select_type(scm_type)
    options_hash = { 'Subversion'       => 'svn_sync',
                     'CVS'              => 'cvs',
                     'Git'              => 'git',
                     'Mercurial'        => 'hg',
                     'Bazaar'           => 'bzr',
                     'Github Repositories' => 'GithubUser' }
    current_selection = scm_type || 'svn_sync'
    options_for_select(options_hash, current_selection)
  end

  def enlistment_branch_name_html_snippet(enlistment)
    return unless enlistment.code_location.branch

    content_tag :span, "Branch: #{enlistment.code_location.branch}", class: 'edit_enlist_branch_name'
  end

  def sidekiq_work_in_progress?
    key = Setting.get_project_enlistment_key(@project.id)
    Setting.get_value(key).try(:present?)
  end
end
