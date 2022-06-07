# frozen_string_literal: true

require 'test_helper'

class HomeDecoratorTest < ActiveSupport::TestCase
  describe 'commit_count' do
    it 'must return thirty day commits_count for most active projects' do
      Rails.cache.clear
      project = create(:project)
      commits_count = 5
      project.best_analysis.thirty_day_summary.update! affiliated_commits_count: commits_count
      _(HomeDecorator.new.commit_count).must_equal [commits_count]
    end

    it 'must handle nil thirty_day_summary values' do
      project = create(:project)

      commits_count = 5
      project.best_analysis.thirty_day_summary.update! affiliated_commits_count: commits_count

      bad_project = create(:project)
      bad_project.best_analysis.thirty_day_summary.destroy
      bad_project.reload

      home_decorator = HomeDecorator.new
      # Simulate a scenario where cached most_active_projects has a project which now misses a thirty_day_summary.
      home_decorator.stubs(:most_active_projects).returns([project, bad_project])

      _(home_decorator.commit_count).must_equal [commits_count]
    end
  end
end
