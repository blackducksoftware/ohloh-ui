class Chart
  def initialize(account)
    @account = account
  end

  def commits_by_project
    @cbp ||= CommitsByProject.new(@account).history_in_date_range
    CHART_DEFAULTS.deep_merge(COMMITS_BY_PROJECT_CHART_DEFAULTS).deep_merge(process_commits_by_project_data).to_json
  end

  def commits_by_language(scope = 'full')
    @cbl ||= CommitsByLanguage.new(@account, context: { scope: scope }).language_experience.to_json
  end

  private

  def process_commits_by_project_data
    years = date_objects(@cbp.first.last.map { |af| af[:month].strftime('%b-%Y') }) if @cbp.present?
    series = @cbp.each_with_object([]) do |(pname, afs), array|
      array.push('name' => pname, 'data' => afs.map { |af| af[:commits] })
    end
    { 'xAxis' => { 'categories' => years }, 'series' => series, 'noCommits' => @cbp.empty? }
  end

  def date_objects(stringified_dates)
    stringified_dates.map do |date_string|
      { commit_month: date_string,
        stringify: date_string =~ /Jan/ ? date_string.split('-').last : '' }
    end
  end
end
