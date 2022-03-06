# frozen_string_literal: true

require 'test_helper'

class AnlysisDecoratorTest < ActiveSupport::TestCase
  let(:analysis) { create(:analysis) }

  describe 'without prev and twelve month summary' do
    it 'commits_difference' do
      commit_difference('commits_difference', -4)
    end

    it 'committers_difference' do
      commit_difference('committers_difference', -4)
    end

    it 'affiliated_commits_difference' do
      commit_difference('affiliated_commits_difference', -2)
    end

    it 'affiliated_committers_difference' do
      commit_difference('affiliated_committers_difference', -2)
    end

    it 'outside_commits_difference' do
      commit_difference('outside_commits_difference', -2)
    end

    it 'outside_committers_difference' do
      commit_difference('outside_committers_difference', -2)
    end
  end

  describe 'with prev and twelve month summary' do
    before do
      create_summaries
    end
    it 'commits_difference' do
      commit_difference('commits_difference', -4)
    end

    it 'committers_difference' do
      commit_difference('committers_difference', -4)
    end

    it 'affiliated_commits_difference' do
      commit_difference('affiliated_commits_difference', -2)
    end

    it 'affiliated_committers_difference' do
      commit_difference('affiliated_committers_difference', -2)
    end

    it 'outside_commits_difference' do
      commit_difference('outside_commits_difference', -2)
    end

    it 'outside_committers_difference' do
      commit_difference('outside_committers_difference', -2)
    end
  end

  describe 'display_chart?' do
    it 'should return false and no_commits when commit count is nil' do
      analysis.stubs(:commit_count).returns(nil)
      _(analysis.decorate.display_chart?).must_equal [false, :no_commits]
    end

    it 'should return false and no_commits when commit count is negative' do
      analysis.stubs(:commit_count).returns(-1)
      _(analysis.decorate.display_chart?).must_equal [false, :no_commits]
    end

    it 'should return false and no_understood_lang when markup_total and logic_total is negative' do
      analysis.stubs(:commit_count).returns(1)
      analysis.stubs(:logic_total).returns(-1)
      analysis.stubs(:markup_total).returns(-1)
      _(analysis.decorate.display_chart?).must_equal [false, :no_understood_lang]
    end

    it 'should return true and nil when logic_total, markup_total and commit_count are present' do
      analysis.stubs(:markup_total).returns(1)
      analysis.stubs(:logic_total).returns(1)
      analysis.stubs(:commit_count).returns(1)
      _(analysis.decorate.display_chart?).must_equal [true, nil]
    end
  end

  describe 'working with nil objects' do
    let(:na) { NilAnalysis.new }
    let(:ad) { AnalysisDecorator.new(na) }

    it 'should have 0 for all differences' do
      _(ad.commits_difference).must_equal 0
      _(ad.committers_difference).must_equal 0
      _(ad.affiliated_commits_difference).must_equal 0
      _(ad.affiliated_committers_difference).must_equal 0
      _(ad.outside_commits_difference).must_equal 0
      _(ad.outside_committers_difference).must_equal 0
    end

    it 'should not display a chart' do
      _(ad.display_chart?).must_equal [false, :no_commits]
    end
  end

  private

  def create_summaries
    create(:twelve_month_summary, analysis: analysis)
    create(:previous_twelve_month_summary, analysis: analysis)
  end

  def commit_difference(column, count)
    _(analysis.decorate.send(column)).must_equal count
  end
end
