# TODO: The target code can't be activated until we have the models that target polymorphizes
class Edit < ActiveRecord::Base
  # belongs_to :target, polymorphic: true
  belongs_to :undoer, class_name: 'Account', foreign_key: 'undone_by'

  scope :not_undone, -> { where(undone: false) }
  scope :similar_to, ->(edit) { similar_to_edit_arel(edit) }

  def previous_value
    previous_edit = find_previous_edit
    previous_edit ? previous_edit.value : nil
  end

  def undo!(editor)
    swap_doneness(true, editor)
  end

  def redo!(editor)
    swap_doneness(false, editor)
  end

  private

  def swap_doneness(undo, editor)
    fail I18n.t('edits.undo_redo_require_editor') unless editor
    fail ActsAsEditable::UndoError, I18n.t(undo ? 'edits.cant_undo' : 'edits.cant_redo') if (undone == undo)
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
    Edit.not_undone
      .similar_to(self)
      .where(Edit.arel_table[:created_at].lt(created_at))
      .order(created_at: :desc)
      .first
  end
end
