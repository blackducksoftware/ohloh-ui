# frozen_string_literal: true

require 'test_helper'

class TopCommitVolumeTest < ActiveSupport::TestCase
  describe 'collection' do
    it 'must return the committer_name and thirty_day_commits count' do
      thirty_day_commits_count = 5
      name_fact = create(:name_fact, thirty_day_commits: thirty_day_commits_count)

      analysis = name_fact.analysis
      results = Analysis::TopCommitVolume.new(analysis, '1 month').collection

      _(results.first[0]).must_equal name_fact.name.name
      _(results.first[1]).must_equal thirty_day_commits_count
    end

    it 'must return the committer_name and twelve_month_commits count' do
      twelve_month_commits_count = 8
      name_fact = create(:name_fact, twelve_month_commits: twelve_month_commits_count)

      analysis = name_fact.analysis
      results = Analysis::TopCommitVolume.new(analysis, '12 months').collection

      _(results.first[0]).must_equal name_fact.name.name
      _(results.first[1]).must_equal twelve_month_commits_count
    end

    it 'must return the committer_name and 50 year commit count' do
      commits_count = 25
      name_fact = create(:name_fact, commits: commits_count)

      analysis = name_fact.analysis
      results = Analysis::TopCommitVolume.new(analysis, '50 years').collection

      _(results.first[0]).must_equal name_fact.name.name
      _(results.first[1]).must_equal commits_count
    end
  end
end
