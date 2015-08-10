require 'test_helper'
require 'test_helpers/commits_by_project_data'
require 'test_helpers/commits_by_language_data'

class ChartTest < ActiveSupport::TestCase
  let(:admin) { create(:admin) }

  let(:user) { create(:account) }

  let(:vita_fact) do
    vita = create(:best_vita, account_id: user.id)
    user.update(best_vita_id: vita.id)
    create(:vita_fact, vita_id: vita.id)
  end

  let(:position1) { create_position(account: user) }
  let(:position2) { create_position(account: user) }

  let(:construct_cbp_data) do
    cbp = CommitsByProjectData.new(position1.id, position2.id).construct
    vita_fact.update(commits_by_project: cbp)
  end

  let(:user_chart) { Chart.new(user) }
  let(:admin_chart) { Chart.new(admin) }

  before do
    construct_cbp_data
  end

  describe 'commits_by_project' do
    it 'should return chart data for user' do
      chart_data = JSON.parse(user_chart.commits_by_project)
      chart_data['noCommits'].must_equal false
      chart_data['series'].first['data'].must_equal [nil] * 13 + [25, 40, 28, 18, 1, 8, 26, 9] + [nil] * 64
      chart_data['series'].first['name'].must_equal position1.project.name
    end

    it 'should return chart data for admin' do
      chart_data = JSON.parse(admin_chart.commits_by_project)
      chart_data['noCommits'].must_equal true
      chart_data['series'].must_equal []
    end
  end

  describe 'commits_by_language' do
    it 'should return chart data for user when' do
      vita_fact.update(commits_by_language: CommitsByLanguageData.construct)

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
