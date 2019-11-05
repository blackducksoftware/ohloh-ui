# frozen_string_literal: true

module TagsHelper
  def tag_icon_link(project)
    link_to_if project.edit_authorized?, t('.tags'), project_tags_path(project), class: 'noborder'
  end

  def tag_links(tag_list, max_tags = tag_list.length)
    tag_list[0..(max_tags - 1)].collect do |tag|
      tag = tag.fix_encoding_if_invalid
      link_to html_escape(tag), tags_path(names: tag), class: 'tag', itemprop: 'keywords'
    end.safe_text(join(' '))
  end

  def tags_left(count)
    return t('tags.reached_maximum') if count.zero?
    return t('tags.over_maximum', overage: count.abs) if count.negative?

    t('tags.number_remaining', count: count, word: count > 1 ? t('tags.tag').pluralize : t('tags.tag'))
  end
end
