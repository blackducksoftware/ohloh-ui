# frozen_string_literal: true

require 'test_helper'

class NilAccountAnalysisFactTest < ActiveSupport::TestCase
  let(:nil_account_analysis_fact) { NilAccountAnalysisFact.new }

  describe 'first_checkin' do
    it 'should return nil' do
      assert_nil nil_account_analysis_fact.first_checkin
    end
  end

  describe 'last_checkin' do
    it 'should return nil' do
      assert_nil nil_account_analysis_fact.last_checkin
    end
  end

  describe 'commits' do
    it 'should return zero' do
      nil_account_analysis_fact.commits.must_equal 0
    end
  end

  describe 'commits_by_language' do
    it 'should be empty' do
      nil_account_analysis_fact.commits_by_language.must_equal []
    end
  end

  describe 'commits_by_project' do
    it 'should be empty' do
      nil_account_analysis_fact.commits_by_project.must_equal []
    end
  end

  describe 'nil?' do
    it 'should return true' do
      nil_account_analysis_fact.nil?.must_equal true
    end
  end

  describe 'blank?' do
    it 'should return true' do
      nil_account_analysis_fact.blank?.must_equal true
    end
  end
end
