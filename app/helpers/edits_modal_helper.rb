# frozen_string_literal: true

module EditsModalHelper
  PROJECT_RELATED_CLASSES = [Alias, Permission, Enlistment, Link, ProjectLicense, RssSubscription].freeze

  def edit_show_value(edit)
    expander(get_edit_value(edit) || edit.value, 300, 340)
  end

  def show_edit_path(edit)
    path = :"#{@parent.class.name.downcase}_edit_path"
    send(path, @parent, edit) if respond_to?(path)
  end

  def get_edit_value(edit)
    if project_related_edit(edit)
      send(:"edit_get_value_#{edit.target.class.name.downcase}", edit)
    elsif organization_or_logo_edit(edit)
      send(:"edit_get_value_#{edit.key}", edit)
    elsif edit.create_edit?
      link_to_create_edit(edit)
    end
  end

  def link_to_create_edit(edit)
    link_to edit.target.to_param, edit.target
  end

  def project_related_edit(edit)
    PROJECT_RELATED_CLASSES.include?(edit.target.class)
  end

  def organization_or_logo_edit(edit)
    edit.key.eql?('logo_id') || edit.key.eql?('org_type')
  end

  def edit_get_value_org_type(edit)
    Organization::ORG_TYPES.invert[edit.value.to_i]
  end

  def edit_get_value_enlistment(edit)
    edit.target.code_location.nice_url if edit.create_edit?
  end

  def edit_get_value_link(edit)
    return link_to edit.target.url, edit.target.url if edit.create_edit?

    edit.key.eql?('link_category_id') ? Link.find_category_by_id(edit.value) : edit.value
  end

  def edit_get_value_projectlicense(edit)
    license = edit.target.license
    link_to license.to_param.to_s, "/licenses/#{license.to_param}"
  end

  def edit_get_value_permission(edit)
    edit.value.to_bool ? I18n.t('edits.managers_only') : I18n.t('edits.everyone')
  end

  def edit_get_value_rsssubscription(edit)
    url = edit.target.rss_feed.url
    safe_url = ERB::Util.html_escape(url)
    link_to safe_url, safe_url
  end

  def edit_get_value_logo_id(edit)
    url = Logo.find(edit.value.to_i).attachment.url(:med)
    link_to url, url
  end

  def edit_get_value_alias(edit)
    edit.create_edit? ? edit.target.commit_name.name : Name.find(edit.value).name
  end
end
