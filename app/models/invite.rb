class Invite < ActiveRecord::Base
  include OnBehalf
  belongs_to :project
  belongs_to :name
  belongs_to :contribution

  after_initialize :set_project_id_name_id

  validates :contribution, presence: true
  validate :unique_invitee

  def set_project_id_name_id
    return if contribution_id.nil?
    self.project_id ||= contribution_id >> 32
    self.name_id ||= contribution_id & 0x7FFFFFFF
  end

  def success_flash
    I18n.t('invites.thank_you_message', name: name.name, email: invitee_email)
  end

  private

  # rubocop:disable Metrics/AbcSize
  def unique_invitee
    return true if errors[:send_limit].any?
    count = self.class.where('invitee_email = ? AND contribution_id = ?', invitee_email, contribution_id).count
    errors.add(:invitee_email, I18n.t('invites.invited_to_claim')) if count > 0
    return if errors[:invitee_email].any?
    errors.add(:invitee_email, I18n.t('invites.invited_to_join')) unless :invitee_exists?
  end
  # rubocop:enable Metrics/AbcSize
  def invitee_exists?
    invitee.nil? && Account.where(email: invitee_email).empty?
  end
end
