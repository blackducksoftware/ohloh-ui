# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  it 'contributor_history' do
    set_date_ranges
    project_analysis = create(:analysis_with_multiple_activity_facts)
    (1..3).to_a.each do |value|
      create(:all_month, month: Date.current - value.month)
    end
    plot_points = project_analysis.contributor_history(@start_date, @end_date)
    plot_points = plot_points.map { |values| values['contributors'].to_i }
    plot_points.count.must_equal 3
  end

  it 'commit_history' do
    project_analysis = create(:analysis_with_multiple_activity_facts)
    set_date_ranges
    (1..3).to_a.each do |value|
      create(:all_month, month: Date.current - value.month)
    end
    plot_points = project_analysis.commit_history(@start_date, @end_date)
    plot_points = plot_points.map { |values| values['commits'].to_i }
    plot_points.count.must_equal 3
  end

  it 'code_total_history' do
    project_analysis = create(:analysis_with_multiple_activity_facts)
    set_date_ranges
    (1..3).to_a.each do |value|
      create(:all_month, month: Date.current - value.month)
    end
    plot_points = project_analysis.code_total_history(@start_date, @end_date)
    plot_points = plot_points.map { |values| values['code_total'].to_i }
    plot_points.count.must_equal 3
  end

  private

  def set_date_ranges
    @date = Date.current
    @end_date = @date.beginning_of_month.to_s
    @start_date = (@date - 3.months).beginning_of_month.to_s
  end
end
