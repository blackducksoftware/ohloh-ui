module ActsAsProtected
  module ClassMethods
    def acts_as_protected(parent: nil, always_protected: false)
      class << self
        send :attr_accessor, :aap_parent
        send :attr_accessor, :aap_always_protected
      end
      @aap_parent = parent
      @aap_always_protected = always_protected
      validate :must_be_authorized

      send :include, ActsAsProtected::InstanceMethods
    end
  end

  def self.included(klass)
    klass.send :extend, ActsAsProtected::ClassMethods
  end

  module InstanceMethods
    def protection_enabled?
      return true if self.class.aap_always_protected
      return aap_parent.protection_enabled? unless aap_parent.nil?
      (permission || Permission.new).remainder
    end

    def edit_authorized?
      return false unless editor_account
      return true if Account::Access.new(editor_account).admin?
      return allow_edit? if respond_to?(:allow_edit?)
      return true if new_record?
      return true unless protection_enabled?
      aap_authorized_editors.include?(editor_account)
    end

    def must_be_authorized
      return unless changed?
      return if edit_authorized?
      errors.add :permission, I18n.t(:edit_permission_failed, klass: self.class)
    end

    private

    def aap_parent
      parent_method = self.class.aap_parent
      parent_method ? send(parent_method) : nil
    end

    def aap_authorized_editors
      aap_parent ? aap_parent.active_managers : authorized_editors
    end
  end
end

ActiveRecord::Base.send :include, ActsAsProtected
