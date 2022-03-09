# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/commits_by_project_data'
require 'test_helpers/commits_by_language_data'

class ChartTest < ActiveSupport::TestCase
  let(:admin) { create(:admin) }
  let(:account) { create_account_with_commits_by_project }
  let(:position1) { account.positions.first }
  let(:position2) { account.positions.last }
  let(:account_chart) { Chart.new(account) }
  let(:admin_chart) { Chart.new(admin) }

  describe 'commits_by_project' do
    it 'should return chart data for user' do
      chart_data = JSON.parse(account_chart.commits_by_project)
      _(chart_data['noCommits']).must_equal false
      _(chart_data['series'].first['data']).must_equal ([nil] * 13) + [25, 40, 28, 18, 1, 8, 26, 9] + ([nil] * 64)
      _(chart_data['series'].first['name']).must_equal position1.project.name
    end

    it 'should return chart data for admin' do
      chart_data = JSON.parse(admin_chart.commits_by_project)
      _(chart_data['noCommits']).must_equal true
      _(chart_data['series']).must_equal []
    end
  end

  describe 'commits_by_language' do
    it 'should return chart data for user when' do
      chart_data = JSON.parse(account_chart.commits_by_language)
      first_lanugage = chart_data['object_array'].first['table']
      _(first_lanugage['language_id']).must_equal '17'
      _(first_lanugage['name']).must_equal 'csharp'
      _(first_lanugage['color_code']).must_equal '4096EE'
      _(first_lanugage['nice_name']).must_equal 'C#'
      _(first_lanugage['commits']).must_equal ([0] * 12) + [24, 37, 27, 16, 1, 8, 26, 9] + ([0] * 64)
      _(first_lanugage['category']).must_equal '0'
    end

    it 'should return chart data for admin' do
      chart_data = JSON.parse(admin_chart.commits_by_language)
      _(chart_data['object_array']).must_equal []
    end
  end
end
