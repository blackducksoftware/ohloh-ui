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
      _(text).must_match I18n.t('projects.not_available')
      _(text).must_match I18n.t('projects.activity')
    end

    it 'should handle new' do
      @project.best_analysis.expects(:activity_level).returns(:new)
      text = project_activity_text(@project, true)
      _(text).must_match I18n.t('projects.new_project')
      _(text).wont_match I18n.t('projects.activity')
    end

    it 'should handle inactive' do
      @project.best_analysis.expects(:activity_level).returns(:inactive)
      text = project_activity_text(@project, true)
      _(text).must_match I18n.t('projects.inactive')
      _(text).wont_match I18n.t('projects.activity')
    end

    it 'should handle very low' do
      @project.best_analysis.expects(:activity_level).returns(:very_low)
      text = project_activity_text(@project, true)
      _(text).must_match I18n.t('projects.very_low')
      _(text).must_match I18n.t('projects.activity')
    end

    it 'should handle low' do
      @project.best_analysis.expects(:activity_level).returns(:low)
      text = project_activity_text(@project, true)
      _(text).must_match I18n.t('projects.low')
      _(text).must_match I18n.t('projects.activity')
    end

    it 'should handle moderate' do
      @project.best_analysis.expects(:activity_level).returns(:moderate)
      text = project_activity_text(@project, true)
      _(text).must_match I18n.t('projects.moderate')
      _(text).must_match I18n.t('projects.activity')
    end
    it 'should handle high' do
      @project.best_analysis.expects(:activity_level).returns(:high)
      text = project_activity_text(@project, true)
      _(text).must_match I18n.t('projects.high')
      _(text).must_match I18n.t('projects.activity')
    end

    it 'should handle very high' do
      @project.best_analysis.expects(:activity_level).returns(:very_high)
      text = project_activity_text(@project, true)
      _(text).must_match I18n.t('projects.very_high')
      _(text).must_match I18n.t('projects.activity')
    end
  end

  describe 'project_activity_text without appending activity' do
    before do
      @project = create(:project)
    end

    it 'should handle not available' do
      @project.best_analysis.expects(:activity_level).returns(:na)
      text = project_activity_text(@project, false)
      _(text).must_match I18n.t('projects.not_available')
      _(text).wont_match I18n.t('projects.activity')
    end

    it 'should handle new' do
      @project.best_analysis.expects(:activity_level).returns(:new)
      text = project_activity_text(@project, false)
      _(text).must_match I18n.t('projects.new_project')
      _(text).wont_match I18n.t('projects.activity')
    end

    it 'should handle inactive' do
      @project.best_analysis.expects(:activity_level).returns(:inactive)
      text = project_activity_text(@project, false)
      _(text).must_match I18n.t('projects.inactive')
      _(text).wont_match I18n.t('projects.activity')
    end

    it 'should handle very low' do
      @project.best_analysis.expects(:activity_level).returns(:very_low)
      text = project_activity_text(@project, false)
      _(text).must_match I18n.t('projects.very_low')
      _(text).wont_match I18n.t('projects.activity')
    end

    it 'should handle low' do
      @project.best_analysis.expects(:activity_level).returns(:low)
      text = project_activity_text(@project, false)
      _(text).must_match I18n.t('projects.low')
      _(text).wont_match I18n.t('projects.activity')
    end

    it 'should handle moderate' do
      @project.best_analysis.expects(:activity_level).returns(:moderate)
      text = project_activity_text(@project, false)
      _(text).must_match I18n.t('projects.moderate')
      _(text).wont_match I18n.t('projects.activity')
    end
    it 'should handle high' do
      @project.best_analysis.expects(:activity_level).returns(:high)
      text = project_activity_text(@project, false)
      _(text).must_match I18n.t('projects.high')
      _(text).wont_match I18n.t('projects.activity')
    end

    it 'should handle very high' do
      @project.best_analysis.expects(:activity_level).returns(:very_high)
      text = project_activity_text(@project, false)
      _(text).must_match I18n.t('projects.very_high')
      _(text).wont_match I18n.t('projects.activity')
    end
  end

  describe 'truncate_project_name' do
    it 'should return content tag if name greater than length' do
      _(truncate_project_name('abc123', 4)).must_match 'a...'
    end

    it 'should return truncated name if it is a link' do
      _(truncate_project_name('abc123', 4, link: true)).must_equal 'a...'
    end

    it 'should return name if name less than length' do
      _(truncate_project_name('abc123')).must_equal 'abc123'
    end
  end

  describe 'project_managers_list' do
    it 'should return project managers list' do
      project_manager = create(:manage)
      @project = project_manager.target
      _(project_managers_list).to_h[:target].match(/(a href|\/\/).*/)
    end
  end

  describe 'project_description_size_breached?' do
    it 'should return false if project description size is less than 800' do
      @project = create(:project_with_less_summary)
      _(project_description_size_breached?(@project)).must_equal false
    end
  end

  describe 'scan_oh_language_mapping' do
    it 'should return matching value' do
      _(scan_oh_language_mapping('Java')).must_equal 'JAVA'
      _(scan_oh_language_mapping('C/C++')).must_equal 'CXX'
      _(scan_oh_language_mapping('C#')).must_equal 'CSHARP'
      _(scan_oh_language_mapping('JavaScript')).must_equal 'JAVASCRIPT'
      _(scan_oh_language_mapping('Ruby')).must_equal 'OTHER'
    end
  end

  describe 'project_separator_text' do
    it 'should return seperation text' do
      _(project_separator_text).must_equal '&nbsp;|&nbsp;'
    end
  end
end
