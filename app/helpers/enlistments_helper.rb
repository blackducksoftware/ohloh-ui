# frozen_string_literal: true

module EnlistmentsHelper
  def options_for_select_type(scm_type)
    options_hash = { 'Git' => 'git',
                     'Github Repositories' => 'GithubUser',
                     'Subversion' => 'svn_sync',
                     'Mercurial' => 'hg',
                     'Bazaar' => 'bzr',
                     'CVS' => 'cvs' }
    current_selection = scm_type || 'git'
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

  def code_location_admin_url(id)
    "#{ApiAccess.fis_public_url}/admin/code_locations/#{id}/jobs"
  end

  # :nocov:
  def code_location_ids_admin_url(id)
    "#{ApiAccess.fis_public_url}/admin/code_locations?ids=#{id.join(',')}"
  end
  # :nocov:
end
