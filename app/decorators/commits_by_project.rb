# frozen_string_literal: true

class CommitsByProject < Cherry::Decorator
  LIMIT = 6

  def history
    cbp = for_all_months
    if cbp.blank?
      { facts: [], start_date: Date.current.next_month.beginning_of_month, max_commits: 0 }
    else
      { facts: cbp, start_date: start_time_of_plot(cbp.first[:month]), max_commits: max_commits }
    end
  end

  def history_in_date_range
    facts = in_date_range.group_by { |c| c[:pname] }
    facts = facts.sort_by { |_, afs| -afs.sum { |af| af[:commits].to_i } }
    facts = reduce_to_limit(facts)
    monthly_commits(facts)
  end

  def chart_data(project_id = nil)
    months_range = TimeParser.months_in_range(history[:start_date], end_date)
    facts = chart_yaxis_data(project_id)
    y_axis = months_range.map do |m|
      facts[m].try(:sum) { |f| f[:commits].to_i } || 0
    end
    x_axis = months_range.map { |m| m.strftime('%b-%Y') }

    { x_axis: x_axis, y_axis: y_axis, max_commits: history[:max_commits] }
  end

  private

  def start_date
    return @start_date if @start_date

    given_start_date = @context[:start_date] || (Time.current - 7.years)
    @start_date = given_start_date.strftime('%Y-%m-01').to_date
  end

  def end_date
    return @end_date if @end_date

    given_end_date = @context[:end_date] || Time.current
    @end_date = given_end_date.strftime('%Y-%m-01').to_date
  end

  def chart_yaxis_data(project_id)
    facts = history[:facts]
    facts = facts.group_by { |f| f[:project_id] }[project_id.to_s] if project_id
    facts ? facts.group_by { |f| f[:month].to_date } : []
  end

  def symbolized
    @symbolized ||= account.decorate.symbolized_commits_by_project
  end

  def positions
    @positions ||= Position.where(id: symbolized.pluck(:position_id).uniq.sort)
                           .includes(:project).references(:all).group_by(&:id)
  end

  def with_positions
    position_ids = positions.keys
    symbolized.select { |c| position_ids.include?(c[:position_id].to_i) }
  end

  def with_positions_in_date_range
    with_positions.select { |c| (start_date..end_date).member?(c[:month].to_date) }
  end

  def in_date_range
    with_positions_in_date_range.map do |c|
      { pname: @positions[c[:position_id].to_i].first.project.name,
        commits: c[:commits].to_i, month: c[:month].to_date }
    end
  end

  def for_all_months
    with_positions.map do |c|
      { project_id: @positions[c[:position_id].to_i].first.project_id.to_s,
        month: c[:month], commits: c[:commits] }
    end
  end

  def start_time_of_plot(first_date)
    return Date.current.beginning_of_month - 5.years if older_than?(first_date, 5)

    first_date.to_s.to_date
  end

  def older_than?(first_date, num_years)
    ((Time.current.beginning_of_month - Time.parse(first_date.to_s).in_time_zone) / 1.year) <= num_years
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
      { month: month, commits: afs.sum { |af| af[:commits].to_i }, pname: 'Other' }
    end
    reduced_facts << ['Others', other_facts]
  end

  def monthly_commits(facts)
    facts.each_with_object({}) do |(pname, afs), hsh|
      hsh[pname] = (afs + months_without_commits).group_by { |a| a[:month] }.map do |_, d|
        d.last.merge(pname: pname).merge(d.first)
      end
      hsh[pname].sort_by! { |a| a[:month] }
    end
  end

  def months_without_commits
    @months_without_commits ||=
      TimeParser.months_in_range(start_date, end_date)
                .each_with_object([]) { |date, array| array << { month: date.to_date, commits: nil } }
  end
end
