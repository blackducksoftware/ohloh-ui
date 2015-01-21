class CommitsByProject < Draper::Decorator
  LIMIT = 6

  decorates :account
  delegate_all

  def initialize(*args)
    super
    @context[:start_date] ||= Time.now.utc - 7.years
    @context[:end_date] ||= Time.now.utc
    @start_date = @context[:start_date].strftime('%Y-%m-01').to_date
    @end_date = @context[:end_date].strftime('%Y-%m-01').to_date
  end

  # TODO: Replaces fetch_historical_commits account/reports.rb
  def history
    cbp = for_all_months
    if cbp.blank?
      { facts: [], start_date: Date.today.next_month.beginning_of_month, max_commits: 0 }
    else
      { facts: cbp, start_date: start_time_of_plot(cbp.first[:month]), max_commits: max_commits }
    end
  end

  # TODO: Replaces commits_history account/reports.rb
  def history_in_date_range
    facts = in_date_range.group_by { |c| c[:pname] }
    facts = facts.sort_by { |_, afs| -afs.sum { |af| af[:commits].to_i } }
    facts = reduce_to_limit(facts)
    monthly_commits(facts)
  end

  # TODO: Replaces regularize_chart_data account/reports.rb
  def chart_data(project_id = nil)
    months_range = h.months_in_range(history[:start_date], @end_date)
    facts = chart_yaxis_data(project_id)
    y_axis = months_range.map { |m| facts[m].try(:sum) { |f| f[:commits] }.to_i }
    x_axis = months_range.map { |m| m.strftime('%b-%Y') }

    { x_axis: x_axis, y_axis: y_axis, max_commits: history[:max_commits] }
  end

  private

  def chart_yaxis_data(project_id)
    facts = history[:facts]
    facts = facts.group_by { |f| f[:project_id] }[project_id.to_s] if project_id
    facts.group_by { |f| f[:month].to_date }
  end

  def symbolized
    @symbolized ||= object.decorate.symbolized_commits_by_project
  end

  def positions
    @positions ||= Position.where(id: symbolized.map { |c| c[:position_id] }.uniq.sort)
                   .includes(:project).references(:all).group_by(&:id)
  end

  def with_positions
    position_ids = positions.keys
    symbolized.select { |c| position_ids.include?(c[:position_id].to_i) }
  end

  def in_date_range
    with_positions.select { |c| (@start_date..@end_date).member?(c[:month].to_date) }.map do |c|
      { pname: @positions[c[:position_id].to_i].first.project.name,
        commits: c[:commits], month: c[:month].to_date }
    end
  end

  def for_all_months
    with_positions.map do |c|
      { project_id: @positions[c[:position_id].to_i].first.project_id.to_s,
        month: c[:month], commits: c[:commits] }
    end
  end

  def start_time_of_plot(first_date)
    time_diff_in_year = (Date.today.beginning_of_month.to_time - first_date.to_time) / 1.year
    return Date.today.beginning_of_month - 5.years if time_diff_in_year <= 5
    first_date.to_date
  end

  def max_commits
    for_all_months.group_by { |fact| fact[:month] }.map do |_, fact|
      fact.sum { |c| c[:commits].to_i }
    end.max
  end

  def reduce_to_limit(facts)
    return facts if facts.length < LIMIT
    reduced_facts = facts.take(LIMIT)
    other_projs = facts.drop(LIMIT).map(&:last)
    other_facts = other_projs.flatten.group_by { |af| af[:month] }.map do |month, afs|
      { month: month, commits: afs.sum { |af| af[:commits].to_i }.to_s, pname: 'Other' }
    end
    reduced_facts << ['Others', other_facts]
  end

  def monthly_commits(facts)
    facts.each_with_object({}) do |(pname, afs), hsh|
      hsh[pname] = (afs + months_without_commits).group_by { |a| a[:month] }.map do |_, d|
        d.last.merge(pname: pname).merge(d.first)
      end
    end
  end

  def months_without_commits
    @months_with_nil_commits ||=
    h.months_in_range(@start_date, @end_date).each_with_object([]) do |date, array|
      array << { month: date.to_date, commits: nil }
    end
  end
end
