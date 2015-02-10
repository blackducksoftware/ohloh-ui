class Invite < ActiveRecord::Base
  include OnBehalf
  belongs_to :project
  belongs_to :name
  belongs_to :contribution

  after_initialize :set_project_id_name_id

  validates :contribution, presence: true
  validate :unique_invitee_wrt_contribution
  validate :duplicate_invitee_email

  def set_project_id_name_id
    return if contribution_id.nil?
    self.project_id ||= contribution_id >> 32
    self.name_id ||= contribution_id & 0x7FFFFFFF
  end

  def success_flash
    I18n.t('invites.thank_you_message', name: name.name, email: invitee_email)
  end

  private

  def unique_invitee_wrt_contribution
    return true if errors[:send_limit].any?
    count = self.class.where('invitee_email = ? AND contribution_id = ?', invitee_email, contribution_id).count
    errors.add(:invitee_email, I18n.t('invites.invited_to_claim')) if count > 0
  end

  def duplicate_invitee_email
    return true unless invitee.nil? && Account.where(email: invitee_email).nil?
    count = self.class.where('invitee_email = ? ', invitee_email).count
    errors.add(:invitee_email, I18n.t('invites.invited_to_join')) if count > 0
  end
end
