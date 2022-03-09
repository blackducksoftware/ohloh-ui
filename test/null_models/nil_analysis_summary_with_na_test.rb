# frozen_string_literal: true

require 'test_helper'

class NilAnalysisSummaryTest < ActiveSupport::TestCase
  let(:nil_analysis_summary_with_na) { NilAnalysisSummaryWithNa.new }

  describe 'commits_count' do
    it 'should return zero' do
      _(nil_analysis_summary_with_na.commits_count).must_equal 'N/A'
    end
  end

  describe 'committer_count' do
    it 'should return zero' do
      _(nil_analysis_summary_with_na.committer_count).must_equal 'N/A'
    end
  end

  describe 'files_modified' do
    it 'should return zero' do
      _(nil_analysis_summary_with_na.files_modified).must_equal 'N/A'
    end
  end

  describe 'committer_count' do
    it 'should return zero' do
      _(nil_analysis_summary_with_na.committer_count).must_equal 'N/A'
    end
  end

  describe 'lines_added' do
    it 'should return zero' do
      _(nil_analysis_summary_with_na.lines_added).must_equal 'N/A'
    end
  end

  describe 'lines_removed' do
    it 'should return zero' do
      _(nil_analysis_summary_with_na.lines_removed).must_equal 'N/A'
    end
  end

  describe 'nil?' do
    it 'should return true' do
      _(nil_analysis_summary_with_na.nil?).must_equal true
    end
  end

  describe 'blank?' do
    it 'should return true' do
      _(nil_analysis_summary_with_na.blank?).must_equal true
    end
  end
end
