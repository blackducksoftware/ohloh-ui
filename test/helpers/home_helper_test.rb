# frozen_string_literal: true

require 'test_helper'

class HomeHelperTest < ActionView::TestCase
  include HomeHelper

  describe 'width' do
    it 'must return user_count * 60' do
      project = stub(user_count: 5)
      width(project, 'most_popular_projects', nil).must_equal project.user_count * 60
    end

    it 'must use the provided max value to divide the user_count * 60' do
      project = stub(user_count: 5)
      max = 5
      project_user_count = (project.user_count * 60) / max
      width(project, 'most_popular_projects', max).must_equal project_user_count
    end

    it 'must return 1 when user_count is nil' do
      project = stub(user_count: nil)
      width(project, 'most_popular_projects', nil).must_equal 1
    end
  end

  describe 'project_count' do
    it 'must return user_count when most_popular_projects' do
      project = stub(user_count: 5)
      project_count(project, 'most_popular_projects').must_equal project.user_count
    end

    it 'must return thirty day commits_count when most_active_projects' do
      project = create(:project)
      commits_count = 5
      project.best_analysis.thirty_day_summary.update! affiliated_commits_count: commits_count
      project_count(project, 'most_active_projects').must_equal commits_count
    end

    it 'must return thirty_day_commits when most_active_contributors ' do
      best_vita = create(:best_vita)
      assert_nil project_count(best_vita.account, 'most_active_contributors')
    end
  end

  describe 'set_link' do
    it 'must return an account link when argument is an account' do
      account = create(:account)
      image_name = 'some_image.png'
      stubs(:avatar_img_path).returns(image_name)
      link = link_to(image_tag(image_name, height: 32, width: 32),
                     account_path(account), class: 'top_ten_icon')
      set_link(account).must_equal(link)
    end

    it 'must return a project link when argument is not an account' do
      project = create(:project)
      name = Faker::Name.name
      stubs(:capture_haml).returns(name)
      link = link_to(name, project_path(project), class: 'top_ten_icon')
      set_link(project).must_equal link
    end
  end

  describe 'set_path' do
    it 'must return an account path when argument is an account' do
      account = create(:account)
      stubs(:h).returns(account.name)
      link = link_to(account.name, account_path(account))
      set_path(account).must_equal link
    end

    it 'must return a project path when argument is an account' do
      project = create(:project)
      stubs(:h).returns(project.name)
      link = link_to(project.name, project_path(project))
      set_path(project).must_equal link
    end
  end
end
