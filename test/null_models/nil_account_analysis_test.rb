# frozen_string_literal: true

require 'test_helper'

class NilAccounAnalysisTest < ActiveSupport::TestCase
  let(:nil_account_analysis) { NilAccountAnalysis.new }

  describe 'account_analysis_fact' do
    it 'should be nil_account_analysis_fact' do
      _(nil_account_analysis.account_analysis_fact.class).must_equal NilAccountAnalysisFact
    end
  end

  describe 'account_analysis_language_facts' do
    it 'should be empty' do
      _(nil_account_analysis.account_analysis_language_facts).must_equal []
    end
  end

  describe 'nil' do
    it 'should be true' do
      _(nil_account_analysis.nil?).must_equal true
    end
  end

  describe 'blank' do
    it 'should be true' do
      _(nil_account_analysis.blank?).must_equal true
    end
  end
end
