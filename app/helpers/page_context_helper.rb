module PageContextHelper
  include ToolHelper
  include ForumHelper

  def account_context
    set_page_context(footer_menu_list: @account.decorate.sidebar_for(current_user),
                     select_footer_nav: :account_summary,
                     select_top_menu_nav: :select_people)
  end

  def organization_context
    set_page_context(footer_menu_list:  @organization.decorate.sidebar,
                     select_footer_nav:  :org_summary,
                     select_top_menu_nav:  :select_organizations)
  end

  def project_context
    set_page_context(footer_menu_list:  @project.decorate.sidebar,
                     select_footer_nav:  :project_summary,
                     select_top_menu_nav:  :select_projects)
  end

  def forum_context
    set_page_context(footer_menu_list:  forums_sidebar)
  end

  def tool_context
    set_page_context(footer_menu_list:  tools_sidebar,
                     select_footer_nav:  :account_summary,
                     select_top_menu_nav:  :select_tools,
                     heading:  'Tools',
                     nav_type: 'sidebar')
  end

  def review_context
    if @project
      project_context
      page_context[:select_footer_nav] = :reviews
    elsif @account
      account_context
      page_context[:select_footer_nav] = :reviews
    end
  end

  def set_page_context(options)
    options.update(nav_type: 'footer_nav') if options[:nav_type].blank?
    page_context.reverse_merge!(options)
  end
end
