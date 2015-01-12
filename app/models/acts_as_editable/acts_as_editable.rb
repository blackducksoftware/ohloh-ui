module ActsAsEditable
  module ClassMethods
    def acts_as_editable(editable_attributes: [], merge_within: 0.seconds)
      send :attr_accessor, :editor_account
      send :attr_accessor, :inside_undo_or_redo
      send :after_create, :create_edit_history!
      send :after_save, :update_edit_history!

      setup_aae_internals!(editable_attributes, merge_within)
      send :include, ActsAsEditable::InstanceMethods
    end

    private

    def setup_aae_internals!(editable_attributes, merge_within)
      class << self
        send :attr_reader, :aae_editable_attributes
        send :attr_reader, :aae_merge_within
      end
      @aae_editable_attributes = editable_attributes
      @aae_merge_within = merge_within
    end
  end

  def self.included(klass)
    klass.send :extend, ActsAsEditable::ClassMethods
  end

  module InstanceMethods
    def destroy
      fail ActsAsEditable::NoEditorAccountError unless editor_account
      CreateEdit.where(target_type: self.class.to_s, target_id: id).first.undo!(editor_account)
    end

    private

    def create_edit_history!
      fail ActsAsEditable::NoEditorAccountError unless editor_account
      CreateEdit.create!(target: self, account_id: editor_account.id, ip: editor_account.last_seen_ip)
    end

    def update_edit_history!
      fail ActsAsEditable::NoEditorAccountError unless editor_account
      record_property_edits! unless inside_undo_or_redo
    end

    def record_property_edits!
      (changed.map(&:to_sym) & editable_attributes).each do |property|
        prop_edit = new_or_merged_property_edit property
        prop_edit.ip = editor_account.last_seen_ip
        prop_edit.value = send property
        prop_edit.save!
      end
    end

    def new_or_merged_property_edit(property)
      prop_edit = PropertyEdit.not_undone.for_property(property).for_target(self).for_editor(editor_account)
      prop_edit = prop_edit.where(PropertyEdit.arel_table[:created_at].gt(Time.now - merge_within))
      prop_edit.first_or_initialize
    end

    def editable_attributes
      self.class.aae_editable_attributes
    end

    def merge_within
      self.class.aae_merge_within
    end
  end
end
