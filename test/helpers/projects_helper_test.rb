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

    it 'should return true if project description size is greater than 800' do
      @project = create(:project_with_invalid_description)
      _(project_description_size_breached?(@project)).must_equal true
    end

    it 'should return nil if project description is nil' do
      @project = create(:project)
      @project.stubs(:description).returns(nil)
      _(project_description_size_breached?(@project)).must_be_nil
    end
  end

  describe 'project_separator_text method' do
    it 'should return the correct separator text' do
      result = project_separator_text

      assert_equal '&nbsp;|&nbsp;', result
    end
  end

  describe 'project_activity_css_class' do
    it 'should return correct css class' do
      @project = create(:project)
      @project.best_analysis.stubs(:activity_level).returns(:high)
      _(send(:project_activity_css_class, @project, 'large')).must_equal 'large_project_activity_level_high'
    end
  end

  describe 'project_activity_level_text_class' do
    it 'should return correct text class' do
      _(send(:project_activity_level_text_class, 'small')).must_equal 'small_project_activity_text'
    end
  end

  describe 'project_activity_level' do
    it 'should return the activity level from best analysis' do
      @project = create(:project)
      @project.best_analysis.stubs(:activity_level).returns(:moderate)
      _(send(:project_activity_level, @project)).must_equal :moderate
    end
  end

  describe 'project_activity_level_class' do
    it 'should call haml_tag with correct css class' do
      @project = create(:project)
      @project.best_analysis.stubs(:activity_level).returns(:high)
      stubs(:haml_tag)
      project_activity_level_class(@project, 'large')
    end
  end

  describe 'project_activity_level_text' do
    it 'should call haml_tag with activity text' do
      @project = create(:project)
      @project.best_analysis.stubs(:activity_level).returns(:high)
      stubs(:haml_tag)
      project_activity_level_text(@project, 'small')
    end
  end

  describe 'project_iusethis_button' do
    it 'should call haml_tag with correct attributes' do
      @project = create(:project)
      stubs(:haml_tag)
      stubs(:concat)
      stubs(:needs_login_or_verification_or_default).returns('new-stack-entry')
      project_iusethis_button(@project)
    end
  end

  describe 'project_twitter_description' do
    before do
      @project = create(:project)
    end

    it 'should return description when analysis is nil' do
      @project.stubs(:description).returns('A test project')
      _(project_twitter_description(@project, nil)).must_equal 'A test project'
    end

    it 'should return empty string when analysis is nil and description is empty' do
      @project.stubs(:description).returns('')
      _(project_twitter_description(@project, nil)).must_equal ''
    end

    it 'should return formatted string when analysis is present' do
      analysis = @project.best_analysis
      analysis.stubs(:code_total).returns(10_000)
      analysis.stubs(:committers_all_time).returns(50)
      @project.best_analysis.stubs(:activity_level).returns(:high)
      @project.stubs(:user_count).returns(100)
      result = project_twitter_description(@project, analysis)
      _(result).must_match 'lines of code'
      _(result).must_match 'contributors'
      _(result).must_match '100 users'
    end
  end

  describe 'show_badges' do
    it 'should return div with badge images' do
      @project = create(:project)
      badge = stub(badge_url: 'https://example.com/badge.png')
      @project.stubs(:badges_summary).returns([badge])
      result = show_badges
      _(result).must_match 'badges'
      _(result).must_match 'https://example.com/badge.png'
    end

    it 'should return empty div when no badges' do
      @project = create(:project)
      @project.stubs(:badges_summary).returns([])
      result = show_badges
      _(result).must_match 'badges'
    end
  end

  describe 'more_badges_link' do
    it 'should return nil when badges count is within limit' do
      @project = create(:project)
      @project.stubs(:project_badges).returns(stub(active: stub(count: 1)))
      _(more_badges_link).must_be_nil
    end

    it 'should return link when badges exceed limit' do
      @project = create(:project)
      @project.stubs(:project_badges).returns(stub(active: stub(count: ProjectBadge::SUMMARY_LIMIT + 1)))
      result = more_badges_link
      _(result).must_match 'more'
    end
  end

  describe 'project_compare_button' do
    it 'should call haml_tag for project compare form' do
      @project = create(:project)
      @session_projects = []
      stubs(:haml_tag)
      stubs(:concat)
      project_compare_button(@project)
    end

    it 'should handle selected session project' do
      @project = create(:project)
      @session_projects = [@project]
      stubs(:haml_tag)
      stubs(:concat)
      project_compare_button(@project)
    end
  end
end
