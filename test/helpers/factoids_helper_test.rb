# frozen_string_literal: true

require 'test_helper'

class FactoidsHelperTest < ActionView::TestCase
  include FactoidsHelper

  before do
    @project = create(:project)
    @analysis = @project.best_analysis
  end

  describe 'get_factoid_type' do
    it 'should return nil when no matching factoid exists' do
      @analysis.stubs(:factoids).returns([])
      result = send(:get_factoid_type, :comments)
      _(result).must_be_nil
    end

    it 'should return matching factoid for comments' do
      factoid = Factoid.find(create(:factoid, analysis: @analysis, type: 'FactoidCommentsVeryHigh').id)
      @analysis.stubs(:factoids).returns([factoid])
      result = send(:get_factoid_type, :comments)
      _(result).must_equal factoid
    end

    it 'should return matching factoid for activity' do
      factoid = Factoid.find(create(:factoid, analysis: @analysis, type: 'FactoidActivityIncreasing').id)
      @analysis.stubs(:factoids).returns([factoid])
      result = send(:get_factoid_type, :activity)
      _(result).must_equal factoid
    end

    it 'should return matching factoid for team' do
      factoid = Factoid.find(create(:factoid, analysis: @analysis, type: 'FactoidTeamSizeOne').id)
      @analysis.stubs(:factoids).returns([factoid])
      result = send(:get_factoid_type, :team)
      _(result).must_equal factoid
    end

    it 'should return matching factoid for age' do
      factoid = Factoid.find(create(:factoid, analysis: @analysis, type: 'FactoidAgeEstablished').id)
      @analysis.stubs(:factoids).returns([factoid])
      result = send(:get_factoid_type, :age)
      _(result).must_equal factoid
    end
  end

  describe 'factiod_info' do
    it 'should return factoid inline, category, and path when factoid exists' do
      factoid = create(:factoid, analysis: @analysis, type: 'FactoidCommentsVeryHigh')
      factoid = Factoid.find(factoid.id)
      @analysis.stubs(:factoids).returns([factoid])
      text, type, url = send(:factiod_info, :comments)
      _(text).must_equal factoid.inline
      _(type).must_equal factoid.category
      _(url).must_equal project_factoids_path(@project, anchor: factoid.type)
    end

    it 'should return unknown info for comments when no factoid exists' do
      @analysis.stubs(:factoids).returns([])
      text, type, url = send(:factiod_info, :comments)
      _(text).must_equal I18n.t('factoids.comments_unknown_inline')
      _(type).must_equal :warning
      _(url).must_be_nil
    end

    it 'should return unknown info for activity when no factoid exists' do
      @analysis.stubs(:factoids).returns([])
      text, type, url = send(:factiod_info, :activity)
      _(text).must_equal I18n.t('factoids.activity_unknown_inline')
      _(type).must_equal :info
      _(url).must_be_nil
    end

    it 'should return unknown info for team when no factoid exists' do
      @analysis.stubs(:factoids).returns([])
      text, type, url = send(:factiod_info, :team)
      _(text).must_equal I18n.t('factoids.team_size_unknown_inline')
      _(type).must_equal :info
      _(url).must_be_nil
    end

    it 'should return unknown info for age when no factoid exists' do
      @analysis.stubs(:factoids).returns([])
      text, type, url = send(:factiod_info, :age)
      _(text).must_equal I18n.t('factoids.age_unknown_inline')
      _(type).must_equal :info
      _(url).must_be_nil
    end
  end

  describe 'factoid_no_factoid_info' do
    it 'should return comments unknown info' do
      text, type, url = send(:factoid_no_factoid_info, :comments)
      _(text).must_equal I18n.t('factoids.comments_unknown_inline')
      _(type).must_equal :warning
      _(url).must_be_nil
    end

    it 'should return activity unknown info' do
      text, type, url = send(:factoid_no_factoid_info, :activity)
      _(text).must_equal I18n.t('factoids.activity_unknown_inline')
      _(type).must_equal :info
      _(url).must_be_nil
    end

    it 'should return team unknown info' do
      text, type, url = send(:factoid_no_factoid_info, :team)
      _(text).must_equal I18n.t('factoids.team_size_unknown_inline')
      _(type).must_equal :info
      _(url).must_be_nil
    end

    it 'should return age unknown info' do
      text, type, url = send(:factoid_no_factoid_info, :age)
      _(text).must_equal I18n.t('factoids.age_unknown_inline')
      _(type).must_equal :info
      _(url).must_be_nil
    end
  end

  describe 'get_factoid_display' do
    it 'should call haml_tag with correct class for existing factoid' do
      factoid = create(:factoid, analysis: @analysis, type: 'FactoidCommentsVeryHigh')
      factoid = Factoid.find(factoid.id)
      @analysis.stubs(:factoids).returns([factoid])

      stubs(:haml_tag)
      stubs(:concat)
      get_factoid_display(:comments)
    end

    it 'should call haml_tag with correct class for unknown factoid' do
      @analysis.stubs(:factoids).returns([])

      stubs(:haml_tag)
      stubs(:concat)
      get_factoid_display(:comments)
    end
  end
end
