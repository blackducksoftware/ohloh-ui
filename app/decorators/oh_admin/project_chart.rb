# frozen_string_literal: true

# :nocov:

class OhAdmin::ProjectChart
  def initialize(period, filter)
    @period = period
    @filter = filter
    @from = period.months.ago.to_date
    @to = Date.yesterday
    project_data
  end

  def render
    chart = PROJECTS_CHART_DEFAULTS
    set_series_data(chart)
    chart['xAxis']['categories'] = @x_axis.uniq
    chart.to_json
  end

  private

  def set_series_data(chart)
    chart['series'][0][:data] = @analyzed.values
    chart['series'][1][:data] = @non_analyzed.values
    chart['series'][2][:data] = @total_count.flatten
  end

  def project_data
    @analyzed = best_analysis_project
    @non_analyzed = no_analysis_project
    monthly_data if @filter == 'monthly'
    @x_axis = []
    @total_count = []
    @filter == 'monthly' ? fill_monthly_gaps : fill_zero_gaps
    sort_by_date
  end

  def monthly_data
    @analyzed = @analyzed.inject({}) { |memo, (k, v)| memo.merge(k.strftime('%b %Y') => v) }
    @non_analyzed = @non_analyzed.inject({}) { |memo, (k, v)| memo.merge(k.strftime('%b %Y') => v) }
  end

  def fill_zero_gaps
    total_count_till_from_date = total_projects(@from)
    (@from..@to).each do |date|
      @analyzed[date] = 0 if @analyzed[date].nil?
      @non_analyzed[date] = 0 if @non_analyzed[date].nil?
      total_count_till_from_date += @non_analyzed[date]
      @total_count << total_count_till_from_date if total_count_till_from_date
      @x_axis << date.strftime('%a, %b %d')
    end
  end

  def fill_monthly_gaps
    months = (@from..@to).map { |date| date.strftime('%b %Y') }.uniq

    monthly_totals = Project
      .where(created_at: @from.beginning_of_month..@to.end_of_month)
      .group("DATE_TRUNC('month', projects.created_at)")
      .count

    base_count = Project.where('created_at < ?', @from.beginning_of_month.beginning_of_day).count

    months.each do |date|
      @analyzed[date] ||= 0
      @non_analyzed[date] ||= 0
      month_key = Date.strptime(date, '%b %Y')
      base_count += monthly_totals[month_key] || 0
      @total_count << base_count
      @x_axis << date
    end
  end

  def sort_by_date
    if @filter == 'monthly'
      @non_analyzed = @non_analyzed.sort_by { |month, _count| Date.strptime(month, '%b %Y') }.to_h
      @analyzed = @analyzed.sort_by { |month, _count| Date.strptime(month, '%b %Y') }.to_h
    else
      @analyzed = @analyzed.sort_by { |date, _count| date }.to_h
      @non_analyzed = @non_analyzed.sort_by { |date, _count| date }.to_h
    end
  end

  def best_analysis_project
    if @filter == 'monthly'
      Project.group("DATE_TRUNC('month', projects.created_at)")
             .where(projects: { created_at: @from.beginning_of_month..@to.end_of_month })
             .count
    else
      Project.group('date(projects.created_at)')
             .where(projects: { created_at: @from..@to })
             .count
    end
  end

  def no_analysis_project
    if @filter == 'monthly'
      Project.active.group("DATE_TRUNC('month', projects.created_at)")
             .where(projects: { created_at: @from.beginning_of_month..@to.end_of_month,
                                best_analysis_id: nil }).count
    else
      Project.active.group('date(projects.created_at)')
             .where(projects: { created_at: @from..@to, best_analysis_id: nil }).count
    end
  end

  def total_projects(date)
    if @filter == 'monthly'
      Project.group("DATE_TRUNC('month', projects.created_at)")
             .where(projects: { created_at: date.to_date.all_month })
             .count
    else
      Project.where('created_at < ?', date.to_date.beginning_of_day).count
    end
  end
end
# :nocov:
