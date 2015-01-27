class OrganizationDecorator < Draper::Decorator
  delegate_all

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def sidebar
    [
      [
        [:org_summary,    h.t(:organization_summary),     h.organization_path(object)],
        [:settings,       h.t(:settings),                 h.settings_organization_path(object)],
        [:widgets,        h.t(:widgets),                  h.organization_widgets_path(object)]
      ],
      [
        [:code_data,      h.t(:project_portfolio)],
        [:projects,       h.t(:claimed_projects),         h.projects_organization_path(object)]
      ]
    ]
  end
end
