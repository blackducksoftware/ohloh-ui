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
    it 'should return :na' do
      nil_analysis.activity_level.must_equal :na
    end
  end

  describe 'name_fact_for' do
    it 'should return false' do
      nil_analysis.name_fact_for(nil).must_equal false
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

  describe 'man_years_from_loc' do
    it 'should return zero' do
      nil_analysis.man_years_from_loc('test').must_equal 0
    end
  end

  describe 'factoids' do
    it 'should return []' do
      nil_analysis.factoids.must_equal []
    end
  end

  describe 'logged_at' do
    it 'should return nil' do
      nil_analysis.logged_at.must_equal nil
    end
  end

  describe 'markup_total' do
    it 'should return zero' do
      nil_analysis.markup_total.must_equal 0
    end
  end

  describe 'build_total' do
    it 'should return zero' do
      nil_analysis.build_total.must_equal 0
    end
  end

  describe 'logic_total' do
    it 'should return zero' do
      nil_analysis.logic_total.must_equal 0
    end
  end

  describe 'code_total' do
    it 'should return zero' do
      nil_analysis.code_total.must_equal 0
    end
  end

  describe 'empty?' do
    it 'should return true' do
      nil_analysis.empty?.must_equal true
    end
  end
end
