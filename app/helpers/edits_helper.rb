module EditsHelper
  def edit_humanize_datetime(datetime)
    now = Time.current
    return t('edits.edit_humanize_datetime', difference: time_ago_in_words(datetime)) if (now - datetime) < 24.hours
    return datetime.strftime('%b %d') if datetime.year == now.year
    datetime.strftime('%b %d, %Y')
  end

  def edit_title_class(edit)
    edit.undone? ? t('edits.undone') : nil
  end

  def edit_show_subject(edit)
    org_edit = true if params[:organization_id].present? || edit.key == 'organization_id' || edit.key == 'org_type'
    html_escape(edit_subject(edit, org_edit))
  end

  private

  def edit_subject(edit, org_page = false)
    project_term = if @parent.is_a?(Project) || @parent.is_a?(Organization)
                     "#{@parent.class} '#{@parent.name}': "
                   else
                     ''
                   end
    undo_term = edit.undone? ? t('edits.dash_undone') : ''
    explanation = org_page ? edit_org_explanation(edit) : edit_explanation(edit)

    project_term + explanation + undo_term
  end

  def edit_org_explanation(edit)
    return edit_org_explanation_org_type(edit) if edit.target_type == 'Organization' && edit.key == 'org_type'
    edit_org_explanation_org_id(edit) || edit_explanation(edit)
  end

  def edit_org_explanation_org_type(edit)
    t('edits.org_explanation_org_type', value: Organization::ORG_TYPES.map { |k, v| [v, k] }.to_h[edit.value.to_i])
  end

  def edit_org_explanation_org_id(edit)
    return nil unless edit.key == 'organization_id' && edit.value
    return t('edits.org_explanation_claim', name: edit.project.name) if params[:organization_id]
    return t('edits.org_explanation_claimed', name: Organization.find(edit.value).name) if params[:project_id]
  end

  def edit_explanation(edit)
    if [Alias, Permission, Enlistment, Link, ProjectLicense, RssSubscription].include?(edit.target.class)
      return send("edit_explanation_#{edit.target.class.name.downcase}".to_sym, edit)
    end
    edit_explanation_generic(edit)
  end

  def edit_explanation_generic(edit)
    if edit.is_a?(PropertyEdit)
      value = edit.value.present? ? truncate(edit.value) : t('edits.nothing')
      t('edits.explanation_property', key: edit.key, value: value)
    else
      t('edits.explanation_create', type: edit.target_type, id: edit.target_id)
    end
  end

  def edit_explanation_alias(edit)
    commit_name = ERB::Util.html_escape(edit.target.commit_name.name)
    if edit.is_a?(PropertyEdit)
      name = ERB::Util.html_escape(Name.find(edit.value).name)
      t('edits.explanation_alias_property', commit_name: commit_name, name: name)
    else
      t('edits.explanation_alias_create', name: commit_name)
    end
  end

  def edit_explanation_enlistment(edit)
    if edit.is_a?(PropertyEdit)
      t('edits.explanation_enlistment_ignored')
    else
      t('edits.explanation_enlistment', url: edit.target.repository.url, name: edit.target.repository.module_name)
    end
  end

  def edit_explanation_link(edit)
    edit.is_a?(PropertyEdit) ? edit_explanation_link_property(edit) : t('edits.explanation_link', id: edit.target.id)
  end

  def edit_explanation_link_property(edit)
    target = edit.target
    if edit.key == 'link_category_id'
      category = target.class.find_category_by_id(edit.value)
      t('edits.explanation_link_key_category', id: target.id, key: edit.key, category: category)
    else
      t('edits.explanation_link_key_value', id: target.id, key: edit.key, value: edit.value)
    end
  end

  def edit_explanation_permission(edit)
    t('edits.explanation_permission', who: (edit.value.to_bool) ? t('edits.managers_only') : t('edits.everyone'))
  end

  def edit_explanation_projectlicense(edit)
    t('edits.explanation_projectlicense', name: edit.target.license.try(:name))
  end

  def edit_explanation_rsssubscription(edit)
    t('edits.explanation_rsssubscription', url: edit.target.rss_feed.url)
  end
end
