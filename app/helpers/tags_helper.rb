module TagsHelper
  def tag_icon
    '<span class="icon-tag"></span>'.html_safe
  end

  def tag_icon_link(project)
    link_to_if project.edit_authorized?, tag_icon, select_project_tags_path(project), class: 'noborder'
  end

  def tag_links(tag_list, max_tags = tag_list.length)
    tag_list[0..(max_tags - 1)].collect do |tag|
      link_to html_escape(tag), tags_path(names: tag), class: 'tag', itemprop: 'keywords'
    end.join(' ').html_safe
  end
end
