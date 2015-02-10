require 'test_helper'

class ChartTest < ActiveSupport::TestCase
  let(:admin) { accounts(:admin) }

  let(:user) do
    account = accounts(:user)
    account.best_vita.vita_fact.destroy
    create(:vita_fact_with_cbl_and_cbp, vita_id: account.best_vita_id)
    account
  end

  let(:user_chart) { Chart.new(user) }
  let(:admin_chart) { Chart.new(admin) }

  describe 'commits_by_project' do
    it 'should return chart data for user' do
      chart_data = JSON.parse(user_chart.commits_by_project)
      chart_data['noCommits'].must_equal false
      chart_data['series'].first['data'].must_equal [nil] * 12 + [25, 40, 28, 18, 1, 8, 26, 9] + [nil] * 65
      chart_data['series'].first['name'].must_equal 'Linux'
    end

    it 'should return chart data for admin' do
      chart_data = JSON.parse(admin_chart.commits_by_project)
      chart_data['noCommits'].must_equal true
      chart_data['series'].must_equal []
    end
  end

  describe 'commits_by_language' do
    it 'should return chart data for user when' do
      chart_data = JSON.parse(user_chart.commits_by_language)
      first_lanugage = chart_data['object_array'].first['table']
      first_lanugage['language_id'].must_equal '17'
      first_lanugage['name'].must_equal 'csharp'
      first_lanugage['color_code'].must_equal '4096EE'
      first_lanugage['nice_name'].must_equal 'C#'
      first_lanugage['commits'].must_equal [0] * 12 + [24, 37, 27, 16, 1, 8, 26, 9] + [0] * 64
      first_lanugage['category'].must_equal '0'
    end

    it 'should return chart data for admin' do
      chart_data = JSON.parse(admin_chart.commits_by_language)
      chart_data['object_array'].must_equal []
    end
  end
end
