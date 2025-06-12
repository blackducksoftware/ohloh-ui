# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/commits_by_project_data'
require 'test_helpers/commits_by_language_data'

class CommitsByProjectTest < ActiveSupport::TestCase
  let(:start_date_val) { 6.years.ago.beginning_of_month }
  let(:account) { create_account_with_commits_by_project }
  let(:position1) { account.positions.first }
  let(:position2) { account.positions.last }

  describe 'history' do
    it 'return commits by project data, start_date and max_commits count' do
      cbp_decorator = CommitsByProject.new(account)
      data = cbp_decorator.history
      _(data[:facts].size).must_equal 10
      _(data[:facts].first[:project_id]).must_equal position1.project.id.to_s
      _(data[:facts].first[:month].to_s).must_equal start_date_str(1)
      _(data[:facts].first[:commits]).must_equal '25'
      _(data[:start_date].to_s).must_equal((start_date_val.to_date + 1.month).to_s)
      _(data[:max_commits]).must_equal 40
    end

    it 'return commits by project data, start_date and max_commits count when commits_by_project is empty' do
      cbp_decorator = CommitsByProject.new(create(:admin))
      data = cbp_decorator.history

      _(data[:facts]).must_equal []
      _(data[:start_date]).must_equal Date.current.next_month.beginning_of_month
      _(data[:max_commits]).must_equal 0
    end
  end

  describe 'history_in_date_range' do
    it 'return commits by project data when date range is specified' do
      start_date = (start_date_val + 4.months).to_date
      end_date = (start_date_val + 6.months).to_date
      cbp_decorator = CommitsByProject.new(account, context: { start_date: start_date, end_date: end_date })

      data = cbp_decorator.history_in_date_range

      _(data.size).must_equal 1
      project_data = data[position1.project.name]
      _(project_data.size).must_equal 3
      _(project_data.first[:month].to_s).must_equal((start_date_val + 4.months).to_date.to_s)
      _(project_data.first[:commits]).must_equal 18
      _(project_data.first[:pname]).must_equal position1.project.name
    end

    it 'return commits by project data when date range is not specified' do
      cbp_decorator = CommitsByProject.new(account)
      data = cbp_decorator.history_in_date_range

      _(data.size).must_equal 2
      project1_data = data[position1.project.name]
      _(project1_data.size).must_equal 85
      _(project1_data.first[:month].to_s).must_equal((start_date_val - 12.months).to_date.to_s)
      _(project1_data.first[:commits]).must_be_nil
      _(project1_data.first[:pname]).must_equal position1.project.name
    end

    it 'should reduce to the limit' do
      commits_data = CommitsByProject.new(account).send(:in_date_range).each { |v| v[:pname] = Faker::Lorem.word }
      CommitsByProject.any_instance.stubs(:in_date_range).returns(commits_data)
      cbp_decorator = CommitsByProject.new(account)
      data = cbp_decorator.history_in_date_range
      _(data.size).must_equal 7
    end
  end

  describe 'chart_data' do
    it 'return commits by project data for chart(x_axis, y_axis and max_commits)' do
      cbp_decorator = CommitsByProject.new(account)
      date_range = calculate_date_range(start_date_val.to_date, Date.current.beginning_of_month)

      chart_data = cbp_decorator.chart_data

      _(chart_data[:y_axis]).must_equal [25, 40, 28, 18, 1, 8, 30, 12] + ([0] * 64)
      _(chart_data[:x_axis]).must_equal date_range
      _(chart_data[:max_commits]).must_equal 40
    end

    it 'return commits by project data for chart(x_axis, y_axis and max_commits) when project_id is given' do
      cbp_decorator = CommitsByProject.new(account)
      start_date = start_date_val.to_date
      end_date = Date.current.beginning_of_month
      date_range = calculate_date_range(start_date, end_date)

      chart_data = cbp_decorator.chart_data

      _(chart_data[:y_axis]).must_equal [25, 40, 28, 18, 1, 8, 30, 12] + ([0] * 64)
      _(chart_data[:x_axis]).must_equal date_range
      _(chart_data[:max_commits]).must_equal 40
    end

    it 'return commits by project data for chart(x_axis, y_axis and max_commits) when commits_by_project is empty' do
      cbp_decorator = CommitsByProject.new(account)
      date_range = calculate_date_range(start_date_val.to_date, Date.current.beginning_of_month)

      chart_data = cbp_decorator.chart_data(position1.project.id)
      _(chart_data[:y_axis]).must_equal [25, 40, 28, 18, 1, 8, 26, 9] + ([0] * 64)
      _(chart_data[:x_axis]).must_equal date_range
      _(chart_data[:max_commits]).must_equal 40
    end
  end

  private

  def start_date_str(month = 0)
    (6.years.ago + month.months).beginning_of_month.strftime('%Y-%m-01 00:00:00')
  end

  def calculate_date_range(start_date, end_date)
    range = (start_date..end_date).map { |m| m.strftime('%b-%Y') }.uniq
    range - [range.first]
  end
end
