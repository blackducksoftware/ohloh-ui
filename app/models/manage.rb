class Manage < ActiveRecord::Base
  MAX_PROJECTS = 200

  belongs_to :account
  belongs_to :target, polymorphic: true
  belongs_to :approver, class_name: 'Account', foreign_key: :approved_by
  belongs_to :destroyer, class_name: 'Account', foreign_key: :deleted_by

  validates :target, presence: true
  validates :target_id, presence: true,
                        uniqueness: { scope: [:target_type, :account_id, :deleted_at],
                                      message: I18n.t(:already_manager) }
  validates :account, presence: true
  validates :message, length: 0..200, allow_nil: true
  validate :enforce_maximum_management

  scope :for_target, ->(target) { where(target_id: target.id) }
  scope :active, -> { where.not(approved_by: nil).where(deleted_by: nil) }
  scope :organizations, -> { where(target_type: 'Organization') }
  scope :projects, -> { where(target_type: 'Project') }

  def enforce_maximum_management
    return unless over_management_limit?
    errors.add :maximum, I18n.t('manage.maximum_exceeded', max_projects: MAX_PROJECTS)
  end

  def approve!(account)
    update_attributes!(approver: account)
  end

  def pending?
    !(approver || destroyer)
  end

  def destroy_by!(destroyer)
    fail I18n.t(:not_authorized) unless can_destroy?(destroyer)
    update_attributes!(deleted_by: destroyer.id)
    destroy
  end

  def destroy
    update_attributes(deleted_at: Time.now.utc)
  end

  private

  def over_management_limit?
    account && account.projects.count >= MAX_PROJECTS
  end

  def can_destroy?(destroyer)
    destroyer == account || target.active_managers.include?(destroyer) || destroyer.admin?
  end
end
