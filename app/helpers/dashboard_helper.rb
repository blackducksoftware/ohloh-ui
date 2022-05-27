# frozen_string_literal: true

module DashboardHelper
  def accounts_link(level)
    "/admin/accounts?q%5Blevel_eq%5D=#{level}&commit=Filter&order=id_desc"
  end

  def last_deployment
    File.exist?(Rails.root.join('REVISION')) ? get_last_deployment : 'N/A'
  end

  def get_last_deployment
    revision, file_modified = get_revision_details
    github_url = "https://github.com/blackducksoftware/ohloh-ui/commit/#{revision}"
    link_text = " (#{revision[0..7]}) "
    deployed = "#{time_ago_in_words(file_modified)} ago "
    link = link_to(link_text, github_url, style: 'color: #fff', target: '_blank', rel: 'noopener')
    (deployed + link).html_safe
  end

  def get_revision_details
    revision_file = File.open(Rails.root.join('REVISION'))
    revision = revision_file.read.strip
    file_modified = revision_file.mtime
    revision_file.close
    [revision, file_modified]
  end

  def accounts_count(level)
    Rails.cache.fetch("Admin-accounts-count-cache_#{level}", expires_in: 1.day) do
      number_with_delimiter(Account.group(:level).size[level])
    end
  end

  def days_projects_count
    projects_count = Rails.cache.fetch('Admin-updated-project-count-cache')
    number_to_percentage((projects_count.to_f / active_projects_count) * 100, precision: 2)
  end

  def weeks_projects_count
    projects_count = Rails.cache.fetch('Admin-updated-project-count-cache')
    number_to_percentage((projects_count.to_f / active_projects_count) * 100, precision: 2)
  end

  def outdated_projects
    projects_count = Rails.cache.fetch('Admin-outdated-project-count-cache') || 0
    number_to_percentage((projects_count.to_f / active_projects_count) * 100, precision: 2)
  end

  def active_projects_count
    Rails.cache.fetch('Admin-active-project-count-cache') { Project.active_enlistments.distinct.size }
  end

  def analyses_count
    Rails.cache.fetch('Admin-project-analyses-count-cache') || 0
  end

  def project_count
    Rails.cache.fetch('Admin-project-count-cache') { Project.active.size }
  end

  def admin_project_trends
    Rails.cache.fetch 'admin_project_trend', expires_in: 1.day do
      render partial: 'project_trend_graph'
    end
  end

  def admin_accounts_trends
    Rails.cache.fetch 'admin_accounts_trend', expires_in: 1.day do
      render partial: 'accounts_trend_graph'
    end
  end
end
