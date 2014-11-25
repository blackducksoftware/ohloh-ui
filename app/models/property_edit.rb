class PropertyEdit < Edit
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
    verb = undo ? I18n.t(:undo) : I18n.t(:redo)
    fail_unless_authorized!(verb)
    fail_unless_action_allowed!(undo, verb)
    target.send(key.to_s + '=', previous_value)
    fail_unless_action_succeeded!(undo)
  end

  def fail_unless_authorized!(verb)
    return if !target.respond_to?(:edit_authorized?) || target.edit_authorized?
    fail ActsAsEditable::UndoError, I18n.t(:aee_you_dont_have_permission, verb: verb)
  end

  def fail_unless_action_allowed!(undo, verb)
    return if (undo && target.allow_undo?(key) && previous_value) || (!undo && target.allow_redo?(key))
    fail ActsAsEditable::UndoError, I18n.t(:aee_generic_cant, verb: verb)
  end

  def fail_unless_action_succeeded!(undo)
    return if target.errors.empty?
    msg = undo ? :aee_undoing_that_makes_an_invalid : :aee_undoing_that_makes_an_invalid
    fail ActsAsEditable::UndoError, I18n.t(msg, target_type: target_type)
  end
end
