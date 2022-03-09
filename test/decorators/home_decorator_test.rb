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
  end
end
