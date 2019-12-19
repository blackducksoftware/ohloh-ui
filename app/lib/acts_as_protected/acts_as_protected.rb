# frozen_string_literal: true

module ActsAsProtected
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_protected(parent: nil, always_protected: false)
      cattr_accessor :aap_parent
      cattr_accessor :aap_always_protected
      self.aap_parent = parent
      self.aap_always_protected = always_protected
      validate :must_be_authorized

      include ActsAsProtected::InstanceMethods
    end
  end

  module InstanceMethods
    def protection_enabled?
      return true if self.class.aap_always_protected
      return send(aap_parent).protection_enabled? unless aap_parent.nil?

      (permission || Permission.new).remainder
    end

    def edit_authorized?
      return false unless verified_editor_account?
      return true if editor_account.access.admin?
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

    def verified_editor_account?
      editor_account && !editor_account.access.disabled? && editor_account.access.verified?
    end

    def aap_authorized_editors
      aap_parent ? send(aap_parent).active_managers : active_managers
    end
  end
end

ActiveRecord::Base.send :include, ActsAsProtected
