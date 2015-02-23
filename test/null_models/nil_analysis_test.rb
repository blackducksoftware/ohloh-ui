require 'test_helper'

class NilAnalysisTest < ActiveSupport::TestCase
  let(:nil_analysis) { NilAnalysis.new }

  describe 'twelve_month_summary' do
    it 'should return nil_analysis_summary object' do
      nil_analysis.twelve_month_summary.class.must_equal NilAnalysisSummary
    end
  end

  describe 'previous_twelve_month_summary' do
    it 'should return nil_analysis_summary object' do
      nil_analysis.previous_twelve_month_summary.class.must_equal NilAnalysisSummary
    end
  end

  describe 'main_language' do
    it 'should return nil' do
      nil_analysis.main_language.must_equal nil
    end
  end

  describe 'activity_level' do
    it 'should return nil' do
      nil_analysis.activity_level.must_equal nil
    end
  end

  describe 'name_fact_for' do
    it 'should return false' do
      nil_analysis.name_fact_for(nil).must_equal false
    end
  end

  describe 'project' do
    it 'should return nil' do
      nil_analysis.project.must_equal nil
    end
  end

  describe 'activity_score' do
    it 'should return zero' do
      nil_analysis.activity_score.must_equal 0
    end
  end

  describe 'updated_on' do
    it 'should return nil' do
      nil_analysis.updated_on.must_equal nil
    end
  end

  describe 'headcount' do
    it 'should return nil' do
      nil_analysis.headcount.must_equal nil
    end
  end

  describe 'first_commit_time' do
    it 'should return nil' do
      nil_analysis.first_commit_time.must_equal nil
    end
  end

  describe 'last_commit_time' do
    it 'should return nil' do
      nil_analysis.last_commit_time.must_equal nil
    end
  end

  describe 'nil?' do
    it 'should return true' do
      nil_analysis.nil?.must_equal true
    end
  end

  describe 'blank?' do
    it 'should return true' do
      nil_analysis.blank?.must_equal true
    end
  end
end
