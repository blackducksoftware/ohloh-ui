require 'test_helper'

class PageContextHelperTest < ActionView::TestCase
  include PageContextHelper
  attr_accessor :page_context

  let(:page_context) { {} }
  let(:admin) { accounts(:admin) }
  let(:linux_organization) { organizations(:linux) }
  let(:linux) { projects(:linux) }
  let(:rails) { forums(:rails) }

  let(:account_menus) do
    { nav_type: 'footer_nav',
      select_footer_nav: :account_summary,
      select_top_menu_nav: :select_people
    }
  end

  let(:organization_menus) do
    { nav_type: 'footer_nav',
      select_footer_nav: :org_summary,
      select_top_menu_nav: :select_organizations
    }
  end
  let(:project_menus) do
    { nav_type: 'footer_nav',
      select_footer_nav: :project_summary,
      select_top_menu_nav: :select_projects
    }
  end
  let(:forum_menus) do
    { nav_type: 'footer_nav'
    }
  end
  let(:tool_menus) do
    { nav_type: 'sidebar',
      select_footer_nav: :account_summary,
      select_top_menu_nav: :select_tools,
      heading: 'Tools'
    }
  end

  it 'should return account page context' do
    @account = accounts(:admin)
    account_context
    page_context.delete(:footer_menu_list)
    page_context.must_equal account_menus
  end

  it 'should return organization page context' do
    @organization = linux_organization
    organization_context
    page_context.delete(:footer_menu_list)
    page_context.must_equal organization_menus
  end

  it 'should return project page context' do
    @project = linux
    project_context
    page_context.delete(:footer_menu_list)
    page_context.must_equal project_menus
  end

  it 'should return forum page context' do
    Object.any_instance.stubs(:current_user_is_admin?).returns(:true)
    @forum = rails
    forum_context
    page_context.delete(:footer_menu_list)
    page_context.must_equal forum_menus
  end

  it 'should return tools page context' do
    tool_context
    page_context.delete(:footer_menu_list)
    page_context.must_equal tool_menus
  end
end
