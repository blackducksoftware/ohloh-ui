module OrganizationsHelper
  def org_pretty_display(value)
    return 'N/A' if value.blank?
    # rubocop:disable Rails/OutputSafety # The values used here are sanitized.
    return '&mdash;'.html_safe if value.to_i.zero?
    # rubocop: enable Rails/OutputSafety
    value
  end

  def org_ticker_markup(diff, previous, klass = nil)
    haml_tag :span, class: "delta #{diff > 0 ? 'good' : 'bad'} #{klass}" do
      percentage = diff.abs.to_f / previous.abs.to_f * 100
      concat "#{'+' if diff > 0}#{diff}"
      concat " (#{percentage.floor}%)" if previous > 0
    end
  end

  def organization_affiliated_committers_stats(account_stat)
    return false unless account_stat
    most_commit_stat = org_most_commit_stat(account_stat)
    most_recent_stat = org_most_recent_stat(account_stat)
    return false unless most_commit_stat['project_id'] && most_recent_stat['project_id']
    {
      most_committed_project: Project.find(most_commit_stat['project_id']),
      most_recent_project: Project.find(most_recent_stat['project_id']),
      max_commits: most_commit_stat['max_commits'],
      last_checkin: most_recent_stat['last_checkin']
    }
  end

  def manager_link(manager, org)
    confirm = t('.confirm', name: h(manager.name.to_s), org: org.name)
    {
      path: reject_organization_manager_path(org, manager),
      options: { method: :post, data: { confirm: confirm }, class: 'btn btn-mini btn-danger' }
    }
  end

  def claim_link_options(org, project)
    {
      class: 'btn btn-small btn-success org-claim-project',
      id: "claim_project_#{project.id}",
      data: { url: claim_project_organization_path(org, project_id: project.to_param) }
    }
  end

  private

  def org_most_commit_stat(account_stat)
    account_stat.sort_by { |hsh| hsh['max_commits'].to_i }.reverse.first || {}
  end

  def org_most_recent_stat(account_stat)
    account_stat.sort_by { |hsh| hsh['last_checkin'] }.reverse.first || {}
  end
end
