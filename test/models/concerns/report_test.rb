require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  it 'contributor_history' do
    set_date_ranges
    project_analysis = create(:analysis_with_multiple_activity_facts)
    (1..3).to_a.each do |value|
      create(:all_month, month: Time.utc(Time.now.utc.year, value, 1))
    end
    plot_points = project_analysis.contributor_history(@start_date, @end_date)
    plot_points = plot_points.map { |values| values['contributors'].to_i }
    plot_points.count.must_equal 3
  end

  it 'commit_history' do
    project_analysis = create(:analysis_with_multiple_activity_facts)
    set_date_ranges
    (1..3).to_a.each do |value|
      create(:all_month, month: Time.utc(Time.now.utc.year, value, 1))
    end
    plot_points = project_analysis.commit_history(@start_date, @end_date)
    plot_points = plot_points.map { |values| values['commits'].to_i }
    plot_points.count.must_equal 3
  end

  it 'code_total_history' do
    project_analysis = create(:analysis_with_multiple_activity_facts)
    set_date_ranges
    (1..3).to_a.each do |value|
      create(:all_month, month: Time.utc(Time.now.utc.year, value, 1))
    end
    plot_points = project_analysis.code__total_history(@start_date, @end_date)
    plot_points = plot_points.map { |values| values['code_total'].to_i }
    plot_points.count.must_equal 3
  end

  private

  def set_date_ranges
    @date = Time.utc(Time.now.utc.year, 1, 1)
    @end_date = Time.now.utc.strftime('%Y-%m-01')
    @start_date = Time.utc(@date.year, 1, 1).strftime('%Y-%m-01')
  end
end
