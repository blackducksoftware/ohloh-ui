class Manage < ActiveRecord::Base
  MAX_PROJECTS = 200

  belongs_to :account
  belongs_to :target, polymorphic: true
  belongs_to :approver, class_name: 'Account', foreign_key: :approved_by
  belongs_to :destroyer, class_name: 'Account', foreign_key: :deleted_by

  validates :target_type, presence: true,
                          uniqueness: { scope: %i[target_id account_id deleted_at],
                                        message: I18n.t('manage.already_manager') }
  validates :account, presence: true
  validates :message, length: 0..200, allow_nil: true
  validate :enforce_maximum_management

  scope :for_target, ->(target) { where(target_id: target.id) }
  scope :for_account, ->(account) { where(account_id: account.id) }
  scope :active, -> { where.not(approved_by: nil).where(deleted_at: nil) }
  scope :pending, -> { where(approved_by: nil).where(deleted_by: nil) }
  scope :not_denied, -> { where(deleted_by: nil) }
  scope :organizations, -> { where(target_type: 'Organization') }
  scope :projects, -> { where(target_type: 'Project') }

  before_validation :auto_approve_if_first, on: :create
  before_save :deliver_emails

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
    raise I18n.t(:not_authorized) unless can_destroy?(destroyer)
    update_attributes!(deleted_by: destroyer.id, deleted_at: Time.current)
  end

  def destroy
    update_attributes(deleted_by: Account.hamster.id, deleted_at: Time.current)
  end

  private

  def over_management_limit?
    account && account.projects.count >= MAX_PROJECTS
  end

  def can_destroy?(destroyer)
    destroyer == account || target.active_managers.include?(destroyer) || destroyer.access.admin?
  end

  def auto_approve_if_first
    self.approver = Account.hamster if !target || target.active_managers.empty?
  end

  def deliver_emails
    ManageMailer.deliver_emails(self)
    true
  end
end
