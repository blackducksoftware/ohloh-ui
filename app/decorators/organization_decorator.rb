class OrganizationDecorator < Draper::Decorator
  delegate_all

  # rubocop:disable Metrics/MethodLength
  def sidebar
    [
      [
        [:org_summary, 'Organization Summary', h.organization_path(object)],
        [:settings, 'Settings', h.settings_organization_path(object)],
        [:widgets, 'Widgets', h.organization_widgets_path(object)]
      ],
      [
        [:code_data, 'Project Portfolio'],
        [:projects, 'Claimed Projects', h.projects_organization_path(object)]
      ]
    ]
  end
end
