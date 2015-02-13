require 'test_helper'

class AnalysisTest < ActiveSupport::TestCase
  describe 'activity_level' do
    it 'defaults to not available' do
      create(:analysis).activity_level.must_equal :na
    end

    it 'returns not available for old analyses' do
      analysis = create(:analysis)
      analysis.update_attributes(updated_on: Time.now - 5.years,
                                 first_commit_time: Time.now - 10.years,
                                 last_commit_time: Time.now - 10.years,
                                 headcount: 10,
                                 min_month: Time.now - 10.years,
                                 logic_total: 100, markup_total: 100, build_total: 100)
      analysis.activity_level.must_equal :na
    end

    it 'returns new for brand new new projects' do
      analysis = create(:analysis)
      analysis.update_attributes(updated_on: Time.now - 5.minute,
                                 first_commit_time: Time.now - 10.minute,
                                 last_commit_time: Time.now - 10.minute,
                                 headcount: 10,
                                 min_month: Time.now - 10.minute,
                                 logic_total: 100, markup_total: 100, build_total: 100)
      analysis.activity_level.must_equal :new
    end

    it 'returns inactive for abandonned projects' do
      analysis = create(:analysis)
      analysis.update_attributes(updated_on: Time.now - 5.minute,
                                 first_commit_time: Time.now - 10.years,
                                 last_commit_time: Time.now - 10.years,
                                 headcount: 10,
                                 min_month: Time.now - 10.years,
                                 logic_total: 100, markup_total: 100, build_total: 100)
      analysis.activity_level.must_equal :inactive
    end

    it 'returns very low for projects with almost no committers' do
      analysis = create(:analysis)
      analysis.update_attributes(updated_on: Time.now - 5.minute,
                                 first_commit_time: Time.now - 10.years,
                                 last_commit_time: Time.now - 10.minute,
                                 headcount: 1,
                                 min_month: Time.now - 10.years,
                                 logic_total: 100, markup_total: 100, build_total: 100)
      analysis.activity_level.must_equal :very_low
    end

    it 'returns correct values for various activity scores' do
      analysis = create(:analysis)
      analysis.update_attributes(updated_on: Time.now - 5.minute,
                                 first_commit_time: Time.now - 10.years,
                                 last_commit_time: Time.now - 10.minute,
                                 headcount: 10,
                                 min_month: Time.now - 10.years,
                                 logic_total: 100, markup_total: 100, build_total: 100,
                                 activity_score: 1)
      analysis.activity_level.must_equal :very_low

      analysis.update_attributes(activity_score: 500_000)
      analysis.activity_level.must_equal :low

      analysis.update_attributes(activity_score: 2_000_000)
      analysis.activity_level.must_equal :moderate

      analysis.update_attributes(activity_score: 5_000_000)
      analysis.activity_level.must_equal :high

      analysis.update_attributes(activity_score: 50_000_000)
      analysis.activity_level.must_equal :very_high
    end
  end
end
