class Chart
  DEFAULTS_SOURCE = "#{Rails.root}/config/charting/defaults.yml"
  COMMITS_BY_PROJECT_SOURCE = "#{Rails.root}/config/charting/commits_by_project.yml"

  def initialize(account)
    @account = account
  end

  def commits_by_project
    @cbp ||= CommitsByProject.new(@account).history_in_date_range
    chart = load_defaults(DEFAULTS_SOURCE)
    chart.deep_merge!(load_defaults(COMMITS_BY_PROJECT_SOURCE))
    chart.deep_merge!(process_commits_by_project_data)
    chart.to_json
  end

  def commits_by_language(scope = 'full')
    @commits_by_lanugage ||=
      CommitsByLanguage.new(@account, context: { scope: @scope }).language_experience.to_json
  end

  private

  def process_commits_by_project_data
    years = date_objects @cbp.first.last.map { |af| af[:month].strftime('%b-%Y') }
    series = @cbp.each_with_object([]) do |(pname, afs), array|
      array.push({ 'name' => pname, 'data' => afs.map { |af| af[:commits] } })
    end
    { 'xAxis' => { 'categories' => years }, 'series' => series, 'noCommits' => @cbp.empty? }
  end

  def load_defaults(source)
    defaults = YAML.load File.read(source)
    defaults.with_indifferent_access
  end

  def date_objects(stringified_dates)
    stringified_dates.map do |date_string|
      { commit_month: date_string, stringify: date_string.match(/Jan/) ? date_string.split('-').last : ''}
    end
  end
end
