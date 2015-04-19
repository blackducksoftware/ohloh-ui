xml.data do
  @daily_commits.each do |commit|
    div_id = "commit_#{ commit['time'].to_i }"
    attributes = {
      start: commit['time'],
      ajaxDescription:
      event_details_project_contributor_url(project_id: @project.id,
                                            contributor_id: params[:contributor_id], time: div_id),
      title: commit['count'].to_i == 1 ? commit['comment'].truncate(40) : "#{ commit['count'] } Commits"
    }
    attributes[:icon] = '/javascripts/api/images/dull-blue-circle-3.png' if commit['count'].to_i > 1
    xml.event(attributes, "<img src='/images/spinner.gif' style='vertical-align:middle;' />")
  end
end
