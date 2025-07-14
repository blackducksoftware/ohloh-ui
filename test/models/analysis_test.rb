# frozen_string_literal: true

require 'test_helper'

class AnalysisTest < ActiveSupport::TestCase
  let(:analysis) do
    create(:analysis, updated_on: 5.years.ago, first_commit_time: 10.years.ago,
                      last_commit_time: 10.years.ago, headcount: 10, min_month: 10.years.ago,
                      logic_total: 100, markup_total: 100, build_total: 100)
  end

  describe 'activity_level' do
    it 'defaults to not available' do
      _(create(:analysis).activity_level).must_equal :na
    end

    it 'returns not available for old analyses' do
      _(analysis.activity_level).must_equal :na
    end

    it 'returns new for brand new new projects' do
      analysis.update(updated_on: 5.minutes.ago, first_commit_time: 10.minutes.ago,
                      last_commit_time: 10.minutes.ago, min_month: 10.minutes.ago)
      _(analysis.activity_level).must_equal :new
    end

    it 'returns inactive for abandonned projects' do
      analysis.update(updated_on: 5.minutes.ago)
      _(analysis.activity_level).must_equal :inactive
    end

    it 'returns very low for projects with almost no committers' do
      analysis.update(updated_on: 5.minutes.ago,
                      last_commit_time: 10.minutes.ago, headcount: 1)
      _(analysis.activity_level).must_equal :very_low
    end

    it 'returns correct values for various activity scores' do
      analysis.update(updated_on: 5.minutes.ago,
                      last_commit_time: 10.minutes.ago,
                      activity_score: 1)
      _(analysis.activity_level).must_equal :very_low

      analysis.update(activity_score: 500_000)
      _(analysis.activity_level).must_equal :low

      analysis.update(activity_score: 2_000_000)
      _(analysis.activity_level).must_equal :moderate

      analysis.update(activity_score: 5_000_000)
      _(analysis.activity_level).must_equal :high

      analysis.update(activity_score: 50_000_000)
      _(analysis.activity_level).must_equal :very_high
    end
  end

  describe 'code_total' do
    it 'should return the sum of all logic, markup and build total' do
      _(analysis.code_total).must_equal 300
    end
  end

  describe 'man_years' do
    it 'should return the calculated value' do
      _(analysis.man_years.round(2)).must_equal 0.05
    end
  end

  describe 'empty?' do
    it 'should return if min_month.nil?' do
      analysis.stubs(:min_month).returns(nil)
      _(analysis.empty?).must_equal true
    end

    it 'should return if code_total is 0' do
      analysis.stubs(:code_total).returns(0)
      _(analysis.empty?).must_equal true
    end
  end

  describe 'cocomo_value' do
    it 'should return the calculated value' do
      _(analysis.cocomo_value).must_equal 2941
    end
  end

  describe 'fresh_and_hot' do
    it 'should return recent analysis' do
      analysis.update(updated_on: 5.minutes.ago,
                      last_commit_time: 10.minutes.ago,
                      hotness_score: 100)
      _(Analysis.fresh_and_hot(analysis.main_language_id)).must_equal [analysis]
    end
  end

  describe 'twelve_month_summary' do
    it 'should return nil analysis summary' do
      new_analysis = create(:analysis)
      analysis.twelve_month_summary.update_column(:analysis_id, new_analysis.id)
      analysis.reload
      _(analysis.twelve_month_summary.class).must_equal NilAnalysisSummary
    end

    it 'should return twelve_month_summary' do
      _(analysis.twelve_month_summary.class).must_equal TwelveMonthSummary
    end
  end

  describe 'previous_twelve_month_summary' do
    it 'should return nil analysis summary' do
      new_analysis = create(:analysis)
      analysis.previous_twelve_month_summary.update_column(:analysis_id, new_analysis.id)
      analysis.reload
      _(analysis.previous_twelve_month_summary.class).must_equal NilAnalysisSummary
    end

    it 'should return nil analysis summary' do
      _(analysis.previous_twelve_month_summary.class).must_equal PreviousTwelveMonthSummary
    end
  end

  describe 'angle' do
    it 'should return the computed angle' do
      analysis.stubs(:hotness_score).returns(20)
      _(analysis.angle).must_equal 87.138
    end
  end
end
