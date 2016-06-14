module Edits::ProjectHelper
  private

  def edit_values_enlistment(edit)
    if edit.is_a?(CreateEdit)
      { new: edit.target.repository.try(:url) }
    elsif edit.key == 'ignore'
      { new: edit.value.present? ? edit.value : t('enlistments.enlistment.description3'),
        old: edit_pre_value_enlistment(edit) }
    end
  end

  def edit_pre_value_enlistment(edit)
    return unless edit.previous_edit
    edit.previous_value.present? ? edit.previous_value : t('enlistments.enlistment.description3')
  end

  def edit_values_link(edit)
    edit_values_link_create(edit) || edit_values_link_category(edit) || edit_values_link_default(edit)
  end

  def edit_values_link_create(edit)
    { new: edit.target.url } if edit.is_a?(CreateEdit)
  end

  def edit_values_link_category(edit)
    return unless edit.key == 'link_category_id'
    values = { new: edit.target.class.find_category_by_id(edit.value) }
    return values unless edit.previous_edit
    values.merge old: edit.previous_edit.target.class.find_category_by_id(edit.previous_value)
  end

  def edit_values_link_default(edit)
    { new: edit.value.present? ? edit.value : t('edits.empty'), old: edit_pre_value_link_default(edit) }
  end

  def edit_pre_value_link_default(edit)
    return unless edit.previous_edit
    edit.previous_value.present? ? edit.previous_value : t('edits.empty')
  end

  def edit_values_projectlicense(edit)
    license = edit.target.license
    { new: { text: license.try(:name), href: license_url(license) } }
  end

  def edit_values_rsssubscription(edit)
    { new: { href: edit.target.rss_feed.url } }
  end

  def edit_values_project(edit)
    return unless edit.target.is_a?(Project)
    edit_values_project_logo(edit) || edit_values_project_create(edit)
  end

  def edit_values_project_logo(edit)
    { new: { img_src: Logo.find(edit.value.to_i).attachment.url(:med) } } if edit.key == 'logo_id'
  end

  def edit_values_project_create(edit)
    { new: { text: edit.target.name,
             href: project_url(edit.target) } } if edit.is_a?(CreateEdit)
  end

  def edit_values_alias(edit)
    edit_values_alias_create(edit) || edit_values_alias_default(edit)
  end

  def edit_values_alias_create(edit)
    return unless edit.is_a?(CreateEdit)
    { new: ERB::Util.html_escape(edit.target.commit_name.name) }
  end

  def edit_values_alias_default(edit)
    { old: ERB::Util.html_escape(edit.target.commit_name.name), new: ERB::Util.html_escape(Name.find(edit.value).name) }
  end
end
