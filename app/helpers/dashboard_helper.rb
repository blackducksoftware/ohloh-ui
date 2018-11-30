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
    deployed = time_ago_in_words(file_modified) + ' ago '
    link = link_to(link_text, github_url, style: 'color: #fff', target: '_blank')
    # rubocop:disable Rails/OutputSafety # Known variables used internally.
    (deployed + link).html_safe
    # rubocop:enable Rails/OutputSafety
  end

  def get_revision_details
    revision_file = File.open(Rails.root.join('REVISION'))
    revision = revision_file.read.strip
    file_modified = revision_file.mtime
    revision_file.close
    [revision, file_modified]
  end

  def accounts_count(level)
    number_with_delimiter(Account.where(level: level).count)
  end

  def updated_projects_count(from, to = nil)
    from = convert_to_datetime(from)
    to = convert_to_datetime(to) || Time.current
    projects_count = Project.active_enlistments.joins(:best_analysis)
                            .where(analyses: { updated_on: from..to }).uniq.count
    number_to_percentage((projects_count.to_f / active_projects_count) * 100, precision: 2)
  end

  def outdated_projects(date)
    projects_count = Project.active_enlistments.joins(:best_analysis)
                            .where('analyses.updated_on < ?', date).uniq.count
    number_to_percentage((projects_count.to_f / active_projects_count) * 100, precision: 2)
  end

  def convert_to_datetime(value)
    Time.current.ago(value).utc if value
  end

  def active_projects_count
    Project.active_enlistments.uniq.count
  end
end
