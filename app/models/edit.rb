class Edit < ActiveRecord::Base
  belongs_to :account
  belongs_to :target, polymorphic: true
  belongs_to :undoer, class_name: 'Account', foreign_key: 'undone_by'
  belongs_to :project
  belongs_to :organization

  before_validation :populate_project
  before_validation :populate_organization

  scope :not_undone, -> { where(undone: false) }
  scope :undone_by_hamster, -> { where(undone: true, undone_by: Account.hamster.id) }
  scope :similar_to, ->(edit) { similar_to_edit_arel(edit) }
  scope :for_target, ->(target) { where(target_type: target.class.to_s, target_id: target.id) }
  scope :for_editor, ->(editor) { where(account_id: editor.id) }
  scope :for_ip, ->(ip) { where(ip: ip) }
  filterable_by %w[key value]

  def previous_value
    previous_edit.try(:value)
  end

  def undo!(editor)
    target.editor_account = editor
    swap_doneness(true, editor)
  end

  def redo!(editor)
    target.editor_account = editor
    swap_doneness(false, editor)
  end

  def previous_edit
    Edit.not_undone
        .similar_to(self)
        .where(Edit.arel_table[:created_at].lt(created_at))
        .order(created_at: :desc)
        .first
  end

  def create_edit?
    type == 'CreateEdit'
  end

  private

  class << self
    private

    def similar_to_edit_arel(edit)
      where(type: edit.class, key: edit.key, target_id: edit.target_id, target_type: edit.target_type)
        .where.not(id: edit.id)
    end
  end

  def swap_doneness(undo, editor)
    check_exceptions(undo, editor)
    Edit.transaction do
      undo ? do_undo : do_redo
      swap_done = update_attributes!(undone: undo, undone_at: Time.current, undone_by: editor.id)
      target.after_undo(editor) if undo && target.respond_to?(:after_undo)
      swap_done
    end
  end

  def check_exceptions(undo, editor)
    raise I18n.t('edits.undo_redo_require_editor') unless editor
    raise ActsAsEditable::UndoError, I18n.t(undo ? 'edits.cant_undo' : 'edits.cant_redo') if undone == undo
  end

  def populate_project
    self.project_id = project_id_for_project || project_id_from_target || project_id_from_targets_target
  end

  def populate_organization
    self.organization_id = org_id_when_associating_to_org || org_id_for_org || org_id_from_non_project_target
  end

  def project_id_for_project
    target.is_a?(Project) ? target.id : nil
  end

  def project_id_from_target
    target.respond_to?(:project_id) ? target.project_id : nil
  end

  def project_id_from_targets_target
    target.respond_to?(:target_id) && target.target_type == 'Project' ? target.target_id : nil
  end

  def org_id_when_associating_to_org
    key == :organization_id ? value : nil
  end

  def org_id_for_org
    target.is_a?(Organization) ? target.id : nil
  end

  def org_id_from_non_project_target
    !target.is_a?(Project) && target.respond_to?(:organization_id) ? target.organization_id : nil
  end
end
