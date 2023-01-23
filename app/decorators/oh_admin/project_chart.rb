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
      @total_count <<  total_count_till_from_date if total_count_till_from_date
      @x_axis << date.strftime('%a, %b %d')
    end
  end

  def fill_monthly_gaps
    (@from..@to).map { |date| date.strftime('%b %Y') }.uniq.each do |date|
      @analyzed[date] = 0 if @analyzed[date].nil?
      @non_analyzed[date] = 0 if @non_analyzed[date].nil?
      monthly_count = total_projects(date) == {} ? 0 : total_projects(date).values
      @total_count << monthly_count
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
      Project.left_joins(:best_analysis).group("DATE_TRUNC('month', projects.created_at)")
             .where('projects.created_at >= ? AND projects.created_at <= ?',
                    @from.beginning_of_month, @to.end_of_month)
             .references(:best_analysis).count
    else
      Project.left_joins(:best_analysis).group('date(projects.created_at)')
             .where('projects.created_at >= ? AND projects.created_at <= ?', @from, @to)
             .references(:best_analysis).count
    end
  end

  def no_analysis_project
    if @filter == 'monthly'
      Project.active.left_joins(:best_analysis).group("DATE_TRUNC('month', projects.created_at)")
             .where('projects.created_at >= ? AND projects.created_at <= ? AND projects.best_analysis_id is NULL',
                    @from.beginning_of_month, @to.end_of_month).references(:best_analysis).count
    else
      Project.active.left_joins(:best_analysis).group('date(projects.created_at)')
             .where('projects.created_at >= ? AND projects.created_at <= ? AND projects.best_analysis_id is NULL',
                    @from, @to).references(:best_analysis).count
    end
  end

  def total_projects(date)
    if @filter == 'monthly'
      Project.group("DATE_TRUNC('month', projects.created_at)")
             .where('projects.created_at >= ? AND projects.created_at <= ?',
                    date.to_date.beginning_of_month, date.to_date.end_of_month)
             .count
    else
      Project.where('DATE(created_at) < ?', date).count
    end
  end
end
# :nocov:
