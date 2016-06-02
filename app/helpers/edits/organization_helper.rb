module Edits::OrganizationHelper
  private

  def edit_key_org(edit)
    if edit.key == 'organization_id' && edit.value
      return edit.target_type if params[:organization_id]
      'Organization' if params[:project_id]
    end || edit_key_rest(edit)
  end

  def edit_org_values(edit)
    edit_values_org_type(edit) || edit_values_org_logo(edit) || edit_values_org_default(edit) || edit_rest_values(edit)
  end

  def edit_values_org_type(edit)
    return unless edit.target_type == 'Organization' && edit.key == 'org_type'
    { new: Organization::ORG_TYPES.map { |k, v| [v, k] }.to_h[edit.value.to_i],
      old: edit_pre_value_org_type(edit) }
  end

  def edit_pre_value_org_type(edit)
    return unless edit.previous_edit
    Organization::ORG_TYPES.map { |k, v| [v, k] }.to_h[edit.previous_value.to_i]
  end

  def edit_values_org_logo(edit)
    return unless edit.target_type == 'Organization' && edit.key == 'logo_id'
    { new: { img_src: Logo.find(edit.value.to_i).attachment.url(:med) } }
  end

  def edit_values_org_default(edit)
    if edit.key == 'organization_id' && edit.value
      edit_values_organization(edit) || edit_values_org_project(edit)
    elsif edit.is_a?(CreateEdit)
      org = edit.target
      { new: { text: org.name, href: organization_url(org) } }
    end
  end

  def edit_values_organization(edit)
    return unless params[:organization_id]
    { new: { text: edit.project.name, href: project_url(edit.project) } }
  end

  def edit_values_org_project(edit)
    return unless params[:project_id]
    org = Organization.find(edit.value)
    { new: { href: organization_url(org), text: org.name },
      old: edit_pre_value_org_project(edit) }
  end

  def edit_pre_value_org_project(edit)
    return unless edit.previous_edit
    org = Organization.find(edit.previous_value)
    { href: organization_url(org), text: org.name }
  end
end
