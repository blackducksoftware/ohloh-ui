# frozen_string_literal: true

module KnowledgeBaseCallbacks
  extend ActiveSupport::Concern

  included do
    after_save :enable_kb_sync!
    after_destroy :enable_kb_sync!
  end

  private

  def enable_kb_sync!
    project_id = get_project_id
    KnowledgeBaseStatus.enable_sync!(project_id) if project_id.present?
  end

  def get_project_id
    case self
    when Project
      id
    when Tagging
      # project is the only taggable item
      taggable_id
    when Organization
      # Get an list of projects in organization, when Organization name, type or url is changed.
      get_organization_project_ids
    else
      project_id
    end
  end

  def get_organization_project_ids
    can_sync = changed && changes.keys.any? { |attr| Organization::KB_SYNC_ATTRS.include?(attr) }
    project_ids if can_sync
  end
end
