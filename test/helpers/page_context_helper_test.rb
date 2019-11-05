# frozen_string_literal: true

require 'test_helper'

class PageContextHelperTest < ActionView::TestCase
  include PageContextHelper
  attr_accessor :page_context

  let(:page_context) { {} }
  let(:admin) { create(:admin) }
  let(:linux_organization) { create(:organization, vanity_url: :linux) }
  let(:linux) { create(:project) }
  let(:rails) { create(:forum) }

  let(:account_menus) do
    {
      select_footer_nav: :account_summary,
      select_top_menu_nav: :select_people,
      page_header: 'accounts/mini_header',
      nav_type: 'footer_nav'
    }
  end

  let(:organization_menus) do
    {
      select_footer_nav: :org_summary,
      select_top_menu_nav: :select_organizations,
      nav_type: 'footer_nav',
      page_header: 'organizations/show/header'
    }
  end

  let(:project_menus) do
    {
      select_footer_nav: :project_summary,
      select_top_menu_nav: :select_projects,
      nav_type: 'footer_nav',
      page_header: 'projects/show/header'
    }
  end

  let(:forum_menus) do
    { nav_type: 'footer_nav' }
  end

  let(:tool_menus) do
    { select_top_menu_nav: :select_tools, nav_type: 'footer_nav' }
  end

  it 'should return account page context' do
    @account = create(:admin)
    # PageContextHelper is included in ApplicationController where current_user is available.
    stubs(:current_user).returns(@account)
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
    Object.any_instance.stubs(:current_user_is_admin?).returns(true)
    @forum = rails
    forum_context(@forum)
    page_context.delete(:footer_menu_list)
    page_context.must_equal forum_menus
  end

  it 'should return tools page context' do
    tool_context
    page_context.delete(:footer_menu_list)
    page_context.must_equal tool_menus
  end
end
