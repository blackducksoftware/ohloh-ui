class CommitsByProjectDecorator < Draper::Decorator
  LIMIT = 6

  decorates :account
  delegate_all

  def initialize(start_date = Time.now.utc - 7.years, end_date = Time.now.utc, project_id = nil)
    @start_date = start_date.strftime("%Y-%m-01").to_date
    @end_date = end_date.strftime("%Y-%m-01").to_date
    @project_id = project_id
  end

  def fetch_historical_commits
    cbp = commits_by_project_for_all_months
    if cbp.blank?
      { facts: [], start_date: Date.today.next_month.beginning_of_month, max_commits: 0 }
    else
      { facts: cbp, start_date: start_time_of_plot(cbp.first['month']),
        max_commits: max_commits }
    end
  end

  def commits_history
    facts = commits_by_project_within_date_range.group_by { |c| c[:pname] }
    facts = facts.sort_by { |pid, afs| -afs.sum { |af| af[:commits].to_i } }
    facts << combine_projects_if_more_than_limit(facts) if facts.length > LIMIT
    handle_projects_without_commits(facts)
  end

  def regularize_chart_data
    data = fetch_historical_commits
    facts = data[:facts].group_by {|f| f['month'].to_date }
    months_range = h.months_till_end_date(data[:start_date], @end_date)

    y_axis = months_range.map { |m| facts[m].try(:sum) { |f| f['commits'].to_i } }
    x_axis = months_range.map { |m| m.strftime('%b-%Y') }

    { x_axis: x_axis, y_axis: y_axis, max_commits: data[:max_commits] }
  end

  private

  def commits_by_project
    position_ids = object.symbolized_commits_by_project.map{ |c| c[:position_id] }.uniq.sort
    @positions = Position.where(id: position_ids).includes(:project).references(:all).group_by(&:id)
    symbolized_commits_by_project.select{ |c| @positions[c[:position_id].to_i].present? }
  end

  def commits_by_project_within_date_range
    commits_by_project.select{ |c| c[:month].to_date === (@start_date..@end_date) }.map do |c|
      { pname: @positions[c[:position_id]].first.project.name,
        commits: c[:commits], month: c[:month].to_date }
    end.compact
  end

  def commits_by_project_for_all_months
    commits_by_project.map do |c|
      { project_id: @positions[pos_id].first.project_id.to_s,
        month: c[:month], commits: c[:commits]}.stringify_keys
    end.compact.find { |c| c[@project_id].present? }
  end

  def start_time_of_plot(first_date)
    h.fix_time_zone(first_date)
    time_diff_in_year = (Date.today.beginning_of_month.to_time - first_date.to_time)/1.year
    return Date.today.beginning_of_month - 5.years if time_diff_in_year <= 5
    first_date.to_date
  end

  def max_commits
    commits_by_project_for_all_months.group_by { |fact| fact['month']}.map do |month, fact|
      fact.sum { |c| c['commits'].to_i }
    end.max
  end

  def combine_projects_if_more_than_limit(facts)
    other_projs = facts.drop(LIMIT).map(&:last)
    other_facts = other_projs.flatten.group_by { |af| af[:month] }.map do |month, afs|
      { month: month, commits: afs.sum { |af| af[:commits].to_i }.to_s, pname: 'Other' }
    end
    ['Others', other_facts]
  end

  def handle_projects_without_commits(facts)
    facts.each_with_object({}) do |hsh, (pname, afs)|
      hsh[pname] ||= []
      h.months_till_end_date(@start_date, @end_date).each do |m|
        af = afs.detect { |af| af[:month].year == @start_date.year && af[:month].month == @start_date.month }
        hsh[pname] << (af || { pname: pname, commits: nil, month: @start_date.to_time})
      end
    end
  end
end
