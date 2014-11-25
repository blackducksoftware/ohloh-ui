# TODO: The target code can't be activated until we have the models that target polymorphizes
class CreateEdit < Edit
  def default_explanation
    I18n.t(:aee_create_edit_explanation, target_type: target_type, target_id: target_id)
  end

  def do_undo
    # target.update_attributes!(deleted: true)
  end

  def do_redo
    # target.update_attributes!(deleted: false)
  end
end
