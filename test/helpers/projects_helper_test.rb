# frozen_string_literal: true

require 'test_helper'

class ProjectsHelperTest < ActionView::TestCase
  include ProjectsHelper
  include ERB::Util

  describe 'project_activity_text with appending activity' do
    before do
      @project = create(:project)
    end

    it 'should handle not available' do
      @project.best_analysis.expects(:activity_level).returns(:na)
      text = project_activity_text(@project, true)
      text.must_match I18n.t('projects.not_available')
      text.must_match I18n.t('projects.activity')
    end

    it 'should handle new' do
      @project.best_analysis.expects(:activity_level).returns(:new)
      text = project_activity_text(@project, true)
      text.must_match I18n.t('projects.new_project')
      text.wont_match I18n.t('projects.activity')
    end

    it 'should handle inactive' do
      @project.best_analysis.expects(:activity_level).returns(:inactive)
      text = project_activity_text(@project, true)
      text.must_match I18n.t('projects.inactive')
      text.wont_match I18n.t('projects.activity')
    end

    it 'should handle very low' do
      @project.best_analysis.expects(:activity_level).returns(:very_low)
      text = project_activity_text(@project, true)
      text.must_match I18n.t('projects.very_low')
      text.must_match I18n.t('projects.activity')
    end

    it 'should handle low' do
      @project.best_analysis.expects(:activity_level).returns(:low)
      text = project_activity_text(@project, true)
      text.must_match I18n.t('projects.low')
      text.must_match I18n.t('projects.activity')
    end

    it 'should handle moderate' do
      @project.best_analysis.expects(:activity_level).returns(:moderate)
      text = project_activity_text(@project, true)
      text.must_match I18n.t('projects.moderate')
      text.must_match I18n.t('projects.activity')
    end
    it 'should handle high' do
      @project.best_analysis.expects(:activity_level).returns(:high)
      text = project_activity_text(@project, true)
      text.must_match I18n.t('projects.high')
      text.must_match I18n.t('projects.activity')
    end

    it 'should handle very high' do
      @project.best_analysis.expects(:activity_level).returns(:very_high)
      text = project_activity_text(@project, true)
      text.must_match I18n.t('projects.very_high')
      text.must_match I18n.t('projects.activity')
    end
  end

  describe 'project_activity_text without appending activity' do
    before do
      @project = create(:project)
    end

    it 'should handle not available' do
      @project.best_analysis.expects(:activity_level).returns(:na)
      text = project_activity_text(@project, false)
      text.must_match I18n.t('projects.not_available')
      text.wont_match I18n.t('projects.activity')
    end

    it 'should handle new' do
      @project.best_analysis.expects(:activity_level).returns(:new)
      text = project_activity_text(@project, false)
      text.must_match I18n.t('projects.new_project')
      text.wont_match I18n.t('projects.activity')
    end

    it 'should handle inactive' do
      @project.best_analysis.expects(:activity_level).returns(:inactive)
      text = project_activity_text(@project, false)
      text.must_match I18n.t('projects.inactive')
      text.wont_match I18n.t('projects.activity')
    end

    it 'should handle very low' do
      @project.best_analysis.expects(:activity_level).returns(:very_low)
      text = project_activity_text(@project, false)
      text.must_match I18n.t('projects.very_low')
      text.wont_match I18n.t('projects.activity')
    end

    it 'should handle low' do
      @project.best_analysis.expects(:activity_level).returns(:low)
      text = project_activity_text(@project, false)
      text.must_match I18n.t('projects.low')
      text.wont_match I18n.t('projects.activity')
    end

    it 'should handle moderate' do
      @project.best_analysis.expects(:activity_level).returns(:moderate)
      text = project_activity_text(@project, false)
      text.must_match I18n.t('projects.moderate')
      text.wont_match I18n.t('projects.activity')
    end
    it 'should handle high' do
      @project.best_analysis.expects(:activity_level).returns(:high)
      text = project_activity_text(@project, false)
      text.must_match I18n.t('projects.high')
      text.wont_match I18n.t('projects.activity')
    end

    it 'should handle very high' do
      @project.best_analysis.expects(:activity_level).returns(:very_high)
      text = project_activity_text(@project, false)
      text.must_match I18n.t('projects.very_high')
      text.wont_match I18n.t('projects.activity')
    end
  end

  describe 'truncate_project_name' do
    it 'should return content tag if name greater than length' do
      truncate_project_name('abc123', false, 4).must_match 'a...'
    end

    it 'should return truncated name if it is a link' do
      truncate_project_name('abc123', true, 4).must_equal 'a...'
    end

    it 'should return name if name less than length' do
      truncate_project_name('abc123').must_equal 'abc123'
    end
  end

  describe 'project_managers_list' do
    it 'should return project managers list' do
      project_manager = create(:manage)
      @project = project_manager.target
      project_managers_list(@project).must_match project_manager.account.name
    end
  end

  describe 'project_description_size_breached?' do
    it 'should return false if project description size is less than 800' do
      @project = create(:project_with_less_summary)
      project_description_size_breached?(@project).must_equal false
    end
  end
end
