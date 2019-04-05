class Chart
  def initialize(account)
    @account = account
  end

  def commits_by_project
    @commits_by_project ||= CommitsByProject.new(@account).history_in_date_range
    CHART_DEFAULTS.deep_merge(COMMITS_BY_PROJECT_CHART_DEFAULTS).deep_merge(process_commits_by_project_data).to_json
  end

  def commits_by_language(scope = 'full')
    @commits_by_language ||= CommitsByLanguage.new(@account, context: { scope: scope }).language_experience.to_json
  end

  private

  def process_commits_by_project_data
    if @commits_by_project.present?
      years = date_objects(@commits_by_project.first.last.map { |af| af[:month].strftime('%b-%Y') })
    end
    series = @commits_by_project.each_with_object([]) do |(pname, afs), array|
      array.push('name' => pname, 'data' => afs.map { |af| af[:commits] })
    end
    { 'xAxis' => { 'categories' => years }, 'series' => series, 'noCommits' => @commits_by_project.empty? }
  end

  def date_objects(stringified_dates)
    stringified_dates.map do |date_string|
      { commit_month: date_string,
        stringify: date_string =~ /Jan/ ? date_string.split('-').last : '' }
    end
  end
end
