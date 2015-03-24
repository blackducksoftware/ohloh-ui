module ProjectLicensesHelper
  def show_license_button(project)
    if project.edit_authorized?
      link_to t('project_licenses.new_declared_license'), new_project_license_path(project), class: 'btn btn-primary'
    else
      disabled_button t('project_licenses.new_declared_license'), class: 'btn-primary'
    end
  end
end
