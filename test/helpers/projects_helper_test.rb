require 'test_helper'

class ProjectsHelperTest < ActionView::TestCase
  include ProjectsHelper

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
end
