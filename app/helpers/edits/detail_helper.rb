module Edits::DetailHelper
  include Edits::ProjectHelper, Edits::OrganizationHelper, Edits::LicenseHelper

  def edit_target_type(edit)
    if [Project, Organization, License].include?(@parent.class)
      "#{@parent.class} '#{@parent.name}'"
    else
      edit_target_type_rest(edit) || edit_target_type_default(edit)
    end.html_safe
  end

  def edit_key(edit)
    org_edit?(edit) ? edit_key_org(edit) : edit_key_rest(edit)
  end

  def edit_values(edit)
    value = org_edit?(edit) ? edit_org_values(edit) : edit_rest_values(edit)
    value[:new] = t('edits.empty') if value[:new].blank?
    value
  end

  def edit_format_value(value)
    edit_format_link(value) || edit_format_image(value) || value
  end

  private

  def edit_generate_link(obj)
    url = if obj.is_a?(Project)
            project_url(obj)
          elsif obj.is_a?(Organization)
            organization_url(obj)
          elsif obj.is_a?(License)
            license_url(obj)
          end
    content_tag :a, obj.name, href: url, target: '_blank'
  end

  def edit_key_rest(edit)
    if edit.key && [Alias, Permission, Enlistment, Link, ProjectLicense, RssSubscription].include?(edit.target.class)
      edit_key_custom(edit)
    end || edit_key_default(edit)
  end

  def edit_key_custom(edit)
    "#{edit.target_type} - #{edit_parse_foreign_key(edit.key)}"
  end

  def edit_key_default(edit)
    if edit.key
      edit_parse_foreign_key(edit.key)
    else
      edit.target_type
    end
  end

  def edit_rest_values(edit)
    if [Alias, Permission, Enlistment, Link, ProjectLicense, RssSubscription].include?(edit.target.class)
      send("edit_values_#{edit.target.class.name.downcase}".to_sym, edit)
    else
      edit_values_project(edit) || edit_values_license(edit) || edit_values_default(edit)
    end
  end

  def edit_values_default(edit)
    if edit.is_a?(CreateEdit)
      { new: edit.target_id }
    else
      { new: edit.value.present? ? edit.value : t('edits.empty'), old: edit.previous_value }
    end
  end

  def edit_values_permission(edit)
    values = { new: edit.value.to_bool ? t('edits.managers_only') : t('edits.everyone') }
    return values unless edit.previous_edit
    values.merge old: edit.previous_value.to_bool ? t('edits.managers_only') : t('edits.everyone')
  end

  def edit_show_path(edit)
    [:license_id, :account_id, :project_id, :organization_id].each do |resource|
      return send("#{resource.to_s.split('_')[0]}_edit_path".to_sym, params[resource], edit) if params.key?(resource)
    end
  end

  def edit_target_type_rest(edit)
    case edit.target.class.name
    when 'Permission'
      "#{edit.target.target_type} [#{edit_generate_link(edit.target.target)}]"
    when 'Alias', 'Enlistment', 'Link', 'ProjectLicense', 'RssSubscription'
      "#{edit.target.project.class} [#{edit_generate_link(edit.target.project)}]"
    end
  end

  def edit_target_type_default(edit)
    "#{edit.target.class} [#{edit_generate_link(edit.target)}]"
  end

  def edit_parse_foreign_key(col_name)
    col_name.split('_id')[0].split('_').map(&:capitalize).join(' ')
  end

  def edit_format_link(value)
    if value.is_a?(String) && value.match(/^http(s*):\/\//)
      content_tag :a, value, href: value, target: '_new'
    elsif value.is_a?(Hash) && value.key?(:href)
      content_tag :a, (value[:text] || value[:href]), href: value[:href], target: '_new'
    end
  end

  def edit_format_image(value)
    content_tag(:img, '', src: value[:img_src]) if value.is_a?(Hash) && value.key?(:img_src)
  end
end
