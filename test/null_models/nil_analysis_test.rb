# frozen_string_literal: true

require 'test_helper'

class NilAnalysisTest < ActiveSupport::TestCase
  let(:nil_analysis) { NilAnalysis.new }

  describe 'twelve_month_summary' do
    it 'should return nil_analysis_summary object' do
      _(nil_analysis.twelve_month_summary.class).must_equal NilAnalysisSummary
    end
  end

  describe 'previous_twelve_month_summary' do
    it 'should return nil_analysis_summary object' do
      _(nil_analysis.previous_twelve_month_summary.class).must_equal NilAnalysisSummary
    end
  end

  describe 'main_language' do
    it 'should return nil' do
      _(nil_analysis.main_language).must_be_nil
    end
  end

  describe 'activity_level' do
    it 'should return :na' do
      _(nil_analysis.activity_level).must_equal :na
    end
  end

  describe 'name_fact_for' do
    it 'should return false' do
      _(nil_analysis.name_fact_for(nil)).must_equal false
    end
  end

  describe 'nil?' do
    it 'should return true' do
      _(nil_analysis.nil?).must_equal true
    end
  end

  describe 'blank?' do
    it 'should return true' do
      _(nil_analysis.blank?).must_equal true
    end
  end

  describe 'man_years_from_loc' do
    it 'should return zero' do
      _(nil_analysis.man_years_from_loc('test')).must_equal 0
    end
  end

  describe 'factoids' do
    it 'should return []' do
      _(nil_analysis.factoids).must_equal []
    end
  end

  describe 'oldest_code_set_time' do
    it 'should return nil' do
      _(nil_analysis.oldest_code_set_time).must_be_nil
    end
  end

  describe 'markup_total' do
    it 'should return zero' do
      _(nil_analysis.markup_total).must_equal 0
    end
  end

  describe 'build_total' do
    it 'should return zero' do
      _(nil_analysis.build_total).must_equal 0
    end
  end

  describe 'logic_total' do
    it 'should return zero' do
      _(nil_analysis.logic_total).must_equal 0
    end
  end

  describe 'code_total' do
    it 'should return zero' do
      _(nil_analysis.code_total).must_equal 0
    end
  end

  describe 'empty?' do
    it 'should return true' do
      _(nil_analysis.empty?).must_equal true
    end
  end

  describe 'updated_on' do
    it 'should return current time with zone info' do
      _(nil_analysis.updated_on.class).must_equal ActiveSupport::TimeWithZone
      assert_in_delta nil_analysis.updated_on, Time.zone.now, 1.second
    end
  end

  describe 'contributor_facts' do
    it 'should return empty' do
      _(nil_analysis.contributor_facts).must_equal []
    end
  end

  describe 'scan_analytics' do
    it 'should return nil' do
      assert_nil nil_analysis.scan_analytics
    end
  end
end
