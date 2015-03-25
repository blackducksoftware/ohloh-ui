require 'test_helper'

class ProjectDecoratorTest < ActiveSupport::TestCase
  let(:linux) { projects(:linux) }
  let(:sidebar) do
    [
      [
        [:project_summary, 'Project Summary', '/p/linux'],
        [:rss, 'News', '/p/linux/rss_articles'],
        [:settings, 'Settings', '/p/linux/settings'],
        [:widgets, 'Sharing Widgets', '/p/linux/widgets'],
        [:similar_projects, 'Related Projects', '/p/linux/similar_projects']
      ],
      [
        [:code_data, 'Code Data'],
        [:languages, 'Languages', '/p/linux/analyses/latest/languages_summary'],
        [:estimated_cost, 'Cost Estimates', '/p/linux/estimated_cost']
      ],
      [
        [:scm_data, 'SCM Data'],
        [:commits, 'Commits', '/p/linux/commits/summary'],
        [:contributors, 'Contributors', '/p/linux/contributors/summary']
      ],
      [
        [:user_data, 'Community Data'],
        [:users, 'Users', '/p/linux/users'],
        [:reviews, 'Ratings & Reviews', '/p/linux/reviews/summary'],
        [:map, 'User & Contributor Locations', '/p/linux/map']
      ]
    ]
  end

  describe 'sidebar' do
    it 'should contain 4 sections' do
      linux.decorate.sidebar.length.must_equal 4
    end

    it 'should return projects menu list' do
      linux.decorate.sidebar.must_equal sidebar
    end
  end

  describe 'icon' do
    it 'should return icon image for project' do
      Icon.any_instance.expects(:image).returns(nil)
      linux.decorate.icon.must_equal nil
    end
  end

  describe 'sorted_link_list' do
    it 'must sort links to return Homepage links first' do
      project = create(:project)
      create(:link, project: project, link_category_id: Link::CATEGORIES[:Community])
      create(:link, project: project, link_category_id: Link::CATEGORIES[:Homepage])

      project.decorate.sorted_link_list.keys.must_equal %w(Homepage Community)
    end

    it 'must sort links by category name' do
      project = create(:project)
      create(:link, project: project, link_category_id: Link::CATEGORIES[:Homepage])
      create(:link, project: project, link_category_id: Link::CATEGORIES[:Forums])
      create(:link, project: project, link_category_id: Link::CATEGORIES[:Community])
      create(:link, project: project, link_category_id: Link::CATEGORIES[:Download])

      project.decorate.sorted_link_list.keys.must_equal %w(Homepage Community Download Forums)
    end

    it 'group the links by category' do
      project = create(:project)
      link_1 = create(:link, project: project, link_category_id: Link::CATEGORIES[:Community])
      link_2 = create(:link, project: project, link_category_id: Link::CATEGORIES[:Community])
      link_3 = create(:link, project: project, link_category_id: Link::CATEGORIES[:Download])

      sorted_links = project.decorate.sorted_link_list
      sorted_links.keys.must_equal %w(Community Download)
      sorted_links['Community'].must_equal [link_1, link_2]
      sorted_links['Download'].must_equal [link_3]
    end
  end
end
