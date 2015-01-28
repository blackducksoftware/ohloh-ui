require 'test_helper'

class CommitsByProjectTest < Draper::TestCase
  before do
    Draper::ViewContext.clear!
  end

  let(:start_date_val) do
    (Time.now - 6.years).beginning_of_month
  end

  def start_date_str(month = 0)
    (Time.now - 6.years + month.months).beginning_of_month.strftime('%Y-%m-01 00:00:00')
  end

  let(:cbp) do
    [{ 'month' => start_date_str, 'commits' => '25', 'position_id' => '1' },
     { 'month' => start_date_str(1), 'commits' => '40', 'position_id' => '1' },
     { 'month' => start_date_str(2), 'commits' => '28', 'position_id' => '1' },
     { 'month' => start_date_str(3), 'commits' => '18', 'position_id' => '1' },
     { 'month' => start_date_str(4), 'commits' => '1', 'position_id' => '1' },
     { 'month' => start_date_str(5), 'commits' => '8', 'position_id' => '1' },
     { 'month' => start_date_str(6), 'commits' => '26', 'position_id' => '1' },
     { 'month' => start_date_str(6), 'commits' => '4', 'position_id' => '2' },
     { 'month' => start_date_str(7), 'commits' => '9', 'position_id' => '1' },
     { 'month' => start_date_str(7), 'commits' => '3', 'position_id' => '2' }]
  end

  let(:user) do
    account = accounts(:user)
    account.best_vita.vita_fact.update(commits_by_project: cbp)
    account
  end

  describe 'history' do
    it 'return commits by project data, start_date and max_commits count' do
      cbp_decorator = CommitsByProject.new(user)
      data = cbp_decorator.history
      data[:facts].size.must_equal 10
      data[:facts].first[:project_id].must_equal '1'
      data[:facts].first[:month].to_s.must_equal start_date_str
      data[:facts].first[:commits].must_equal '25'
      data[:start_date].to_s.must_equal start_date_val.to_date.to_s
      data[:max_commits].must_equal 40
    end

    it 'return commits by project data, start_date and max_commits count when commits_by_project is empty' do
      cbp_decorator = CommitsByProject.new(create(:admin))
      data = cbp_decorator.history

      data[:facts].must_equal []
      data[:start_date].must_equal Date.today.next_month.beginning_of_month
      data[:max_commits].must_equal 0
    end
  end

  describe 'history_in_date_range' do
    it 'return commits by project data when date range is specified' do
      start_date = (start_date_val + 4.months).to_date
      end_date = (start_date_val + 6.months).to_date
      cbp_decorator = CommitsByProject.new(user, context: { start_date: start_date, end_date: end_date })

      data = cbp_decorator.history_in_date_range

      data.size.must_equal 1
      data['Linux'].size.must_equal 3
      data['Linux'].first[:month].to_s.must_equal((start_date_val + 4.months).to_date.to_s)
      data['Linux'].first[:commits].must_equal '1'
      data['Linux'].first[:pname].must_equal 'Linux'
    end

    it 'return commits by project data when date range is not specified' do
      cbp_decorator = CommitsByProject.new(user)
      data = cbp_decorator.history_in_date_range

      data.size.must_equal 1
      data['Linux'].size.must_equal 85
      data['Linux'].first[:month].to_s.must_equal start_date_val.to_date.to_s
      data['Linux'].first[:commits].must_equal '25'
      data['Linux'].first[:pname].must_equal 'Linux'
    end
  end

  describe 'chart_data' do
    it 'return commits by project data for chart(x_axis, y_axis and max_commits)' do
      cbp_decorator = CommitsByProject.new(user)
      start_date = start_date_val.to_date
      end_date = Date.today.beginning_of_month
      date_range = (start_date..end_date).map { |m| m.strftime('%b-%Y') }.uniq

      chart_data = cbp_decorator.chart_data

      chart_data[:y_axis].must_equal [25, 40, 28, 18, 1, 8, 30, 12] + [0] * 65
      chart_data[:x_axis].must_equal date_range
      chart_data[:max_commits].must_equal 40
    end

    it 'return commits by project data for chart(x_axis, y_axis and max_commits) when project_id is given' do
      cbp_decorator = CommitsByProject.new(user)
      start_date = start_date_val.to_date
      end_date = Date.today.beginning_of_month
      date_range = (start_date..end_date).map { |m| m.strftime('%b-%Y') }.uniq

      chart_data = cbp_decorator.chart_data

      chart_data[:y_axis].must_equal [25, 40, 28, 18, 1, 8, 30, 12] + [0] * 65
      chart_data[:x_axis].must_equal date_range
      chart_data[:max_commits].must_equal 40
    end

    it 'return commits by project data for chart(x_axis, y_axis and max_commits) when commits_by_project is empty' do
      cbp_decorator = CommitsByProject.new(user)
      end_date = Date.today.beginning_of_month
      date_range = (start_date_val.to_date..end_date).map { |m| m.strftime('%b-%Y') }.uniq

      chart_data = cbp_decorator.chart_data(projects(:linux).id)
      chart_data[:y_axis].must_equal [25, 40, 28, 18, 1, 8, 30, 12] + [0] * 65
      chart_data[:x_axis].must_equal date_range
      chart_data[:max_commits].must_equal 40
    end
  end
end
