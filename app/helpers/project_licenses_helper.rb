# frozen_string_literal: true

module ProjectLicensesHelper
  def show_license_button(project)
    button_class = 'btn btn-primary new-license'
    if project.edit_authorized?
      link_to t('project_licenses.new_declared_license'), new_project_license_path(project), class: button_class
    else
      disabled_button t('project_licenses.new_declared_license'), class: button_class
    end
  end
end
