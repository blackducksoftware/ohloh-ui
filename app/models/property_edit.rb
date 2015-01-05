class PropertyEdit < Edit
  scope :for_property, ->(property) { where(key: property) }

  def default_explanation
    new_value = value.present? ? value.to_s.truncate(30, omission: '…') : "[#{I18n.t(:nothing)}]"
    I18n.t(:aee_create_property_explanation, key: key, new_value: new_value)
  end

  def do_undo
    do_swap(true)
  end

  def do_redo
    do_swap(false)
  end

  private

  def do_swap(undo)
    verb = undo ? I18n.t('edits.undo') : I18n.t('edits.redo')
    fail_unless_authorized!(verb)
    fail_unless_action_allowed!(undo, verb)
    update_target(undo)
    fail_unless_action_succeeded!(verb)
  end

  def update_target(undo)
    target.inside_undo_or_redo = true
    target.update_attributes(key.to_s => undo ? previous_value : value)
    target.inside_undo_or_redo = false
  end

  def fail_unless_authorized!(verb)
    return if !target.respond_to?(:edit_authorized?) || target.edit_authorized?
    fail ActsAsEditable::UndoError, I18n.t('edits.you_dont_have_permission', verb: verb)
  end

  def fail_unless_action_allowed!(undo, verb)
    return if (undo && target.allow_undo?(key) && previous_value) || (!undo && target.allow_redo?(key))
    fail ActsAsEditable::UndoError, I18n.t('edits.generic_cant', verb: verb)
  end

  def fail_unless_action_succeeded!(verb)
    return if target.errors.empty?
    fail ActsAsEditable::UndoError, I18n.t('edits.causes_errors', verb: verb)
  end
end
