module ActsAsEditable
  module ClassMethods
    def acts_as_editable(editable_attributes: [], merge_within: 0.seconds, edit_description: nil)
      send :attr_accessor, :editor_account
      send :before_save, :update_edit_history
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

  def update_edit_history
    fail ActsAsEditable::NoEditorAccountError unless editor_account
    edit_desc_callback = self.class.aae_edit_description
    send edit_desc_callback if edit_desc_callback
    self.class.aae_editable_attributes && self.class.aae_merge_within
  end

  def allow_undo?(_)
    true
  end

  def allow_redo?(_)
    true
  end
end

ActiveRecord::Base.send :include, ActsAsEditable
