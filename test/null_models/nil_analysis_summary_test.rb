require 'test_helper'

class NilAnalysisSummaryTest < ActiveSupport::TestCase
  let(:nil_analysis_summary) { NilAnalysisSummary.new }

  describe 'affiliated_committers_count' do
    it 'should return zero' do
      nil_analysis_summary.affiliated_committers_count.must_equal 0
    end
  end

  describe 'affiliated_commits_count' do
    it 'should return zero' do
      nil_analysis_summary.affiliated_commits_count.must_equal 0
    end
  end

  describe 'outside_committers_count' do
    it 'should return zero' do
      nil_analysis_summary.outside_committers_count.must_equal 0
    end
  end

  describe 'outside_commits_count' do
    it 'should return zero' do
      nil_analysis_summary.outside_commits_count.must_equal 0
    end
  end

  describe 'commits_count' do
    it 'should return zero' do
      nil_analysis_summary.commits_count.must_equal 0
    end
  end

  describe 'committer_count' do
    it 'should return zero' do
      nil_analysis_summary.committer_count.must_equal 0
    end
  end
end
