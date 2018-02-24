module DashboardHelper
  def accounts_link(level)
    "/admin/accounts?q%5Blevel_eq%5D=#{level}&commit=Filter&order=id_desc"
  end

  def last_deployment
    File.exist?("#{Rails.root}/REVISION") ? get_last_deployment : 'N/A'
  end

  def get_last_deployment
    revision, file_modified = get_revision_details
    github_url = "https://github.com/blackducksoftware/ohloh-ui/commit/#{revision}"
    link_text = " (#{revision[0..7]}) "
    deployed = time_ago_in_words(file_modified) + ' ago '
    link = link_to(link_text, github_url, style: 'color: #fff', target: '_blank')
    (deployed + link).html_safe
  end

  def get_revision_details
    revision_file = File.open("#{Rails.root}/REVISION")
    revision = revision_file.read.strip
    file_modified = revision_file.mtime
    revision_file.close
    [revision, file_modified]
  end

  def accounts_count(level)
    number_with_delimiter(Account.where(level: level).count)
  end
end
