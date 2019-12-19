# frozen_string_literal: true

class PropertyEdit < Edit
  scope :for_property, ->(property) { where(key: property) }

  def do_undo
    do_swap(true)
  end

  def do_redo
    do_swap(false)
  end

  def allow_undo?
    key && (previous_value || !target.respond_to?(:allow_undo_to_nil?) || target.allow_undo_to_nil?(key.to_sym))
  end

  def allow_redo?
    key && (!target.respond_to?(:allow_redo?) || target.allow_redo?(key.to_sym))
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
    target.update(key => undo ? previous_value : value)
    target.inside_undo_or_redo = false
  end

  def fail_unless_authorized!(verb)
    return if !target.respond_to?(:edit_authorized?) || target.edit_authorized?

    raise ActsAsEditable::UndoError, I18n.t('edits.you_dont_have_permission', verb: verb)
  end

  def fail_unless_action_allowed!(undo, verb)
    return if (undo && allow_undo?) || (!undo && allow_redo?)

    raise ActsAsEditable::UndoError, I18n.t('edits.generic_cant', verb: verb)
  end

  def fail_unless_action_succeeded!(verb)
    return if target.errors.empty?

    raise ActsAsEditable::UndoError, I18n.t('edits.causes_errors', verb: verb)
  end
end
