module ActsAsEditable
  module ClassMethods
    def acts_as_editable(editable_attributes: [], merge_within: 0.seconds, edit_description: nil)
      send :attr_accessor, :editor_account
      send :attr_accessor, :inside_undo_or_redo
      send :after_create, :record_create_edit!
      send :after_save, :update_edit_history

      setup_aae_internals!(editable_attributes, merge_within, edit_description)
      send :include, ActsAsEditable::InstanceMethods
    end

    private

    def setup_aae_internals!(editable_attributes, merge_within, edit_description)
      class << self
        send :attr_reader, :aae_editable_attributes
        send :attr_reader, :aae_merge_within
        send :attr_reader, :aae_edit_description
      end
      @aae_editable_attributes = editable_attributes
      @aae_merge_within = merge_within
      @aae_edit_description = edit_description
    end
  end

  def self.included(klass)
    klass.send :extend, ActsAsEditable::ClassMethods
  end

  module InstanceMethods
    def allow_undo?(_)
      true
    end

    def allow_redo?(_)
      true
    end

    def destroy
      fail ActsAsEditable::NoEditorAccountError unless editor_account
      create_edit.undo!(editor_account)
      freeze
    end

    def update_edit_history
      fail ActsAsEditable::NoEditorAccountError unless editor_account
      edit_desc_callback = self.class.aae_edit_description
      send edit_desc_callback if edit_desc_callback
      record_property_edits! unless inside_undo_or_redo
    end

    private

    def create_edit
      CreateEdit.where(target_type: self.class.to_s, target_id: id).first
    end

    def record_create_edit!
      fail ActsAsEditable::NoEditorAccountError unless editor_account
      CreateEdit.create!(target: self, account_id: editor_account.id, ip: editor_account.last_seen_ip)
    end

    def record_property_edits!
      (changed & self.class.aae_editable_attributes.map(&:to_s)).each do |property|
        prop_edit = new_or_merged_property_edit(property)
        prop_edit.ip = editor_account.last_seen_ip
        prop_edit.value = send(property.to_sym)
        prop_edit.save!
      end
    end

    def new_or_merged_property_edit(property)
      prop_edit = PropertyEdit.not_undone.for_property(property).for_target(self).for_editor(editor_account)
      prop_edit = prop_edit.where(PropertyEdit.arel_table[:created_at].gt(Time.now - self.class.aae_merge_within))
      prop_edit.first_or_initialize
    end
  end
end

ActiveRecord::Base.send :include, ActsAsEditable
