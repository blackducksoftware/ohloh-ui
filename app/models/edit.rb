# TODO: The target code can't be activated until we have the models that target polymorphizes
class Edit < ActiveRecord::Base
  # belongs_to :target, polymorphic: true

  scope :not_undone, -> { where(undone: false) }
  scope :similar_to, ->(edit) { similar_to_edit_arel(edit) }

  def redone_by
    undone ? nil : undone_by
  end

  def previous_value
    previous_edit = find_previous_edit
    previous_edit ? previous_edit.value : nil
  end

  def undo(editor)
    swap_doneness(true, editor)
  end

  def redo(editor)
    swap_doneness(false, editor)
  end

  def explanation
    # if target && target.class.aae_edit_description
    #   target.send(target.class.aae_edit_description, self)
    # else
    #   default_explanation
    # end
  end

  private

  def swap_doneness(undo, editor)
    fail UndoError(I18n.t(undo ? :aee_cant_undo : aee_cant_redo)) if (undone == undo)
    Edit.transaction do
      undo ? do_undo : do_redo
      self.update_attributes!(undone: undo, undone_at: Time.now.utc, undone_by: editor.id)
    end
  end

  def self.similar_to_edit_arel(edit)
    where(type: edit.class, key: edit.key, target_id: edit.target_id, target_type: edit.target_type)
      .where.not(id: edit.id)
  end

  def find_previous_edit
    puts "========================="
    puts Edit.count
    puts "========================="
    Edit.not_undone
      .similar_to(self)
      .where(Edit.arel_table[:created_at].lt(created_at))
      .order(created_at: :desc)
      .first
  end
end
