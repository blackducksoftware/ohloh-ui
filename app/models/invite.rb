class Invite < ActiveRecord::Base
  include OnBehalf
  belongs_to :project
  belongs_to :name
  belongs_to :contribution

  after_initialize :set_project_id_name_id

  validates :contribution, presence: true
  # validates :invitee_email, uniqueness: { scope: [:contribution_id], message: I18n.t('invites.invited_to_claim') }
  # validates :invitee_email, uniqueness: { unless: :unique_invitee?, message: I18n.t('invites.invited_to_join') }

  def set_project_id_name_id
    # self.project_id ||= contribution_id >> 32
    self.project_id ||= contribution_id
    self.name_id ||= contribution_id & 0x7FFFFFFF
  end

  def success_flash
    I18n.t('invites.thank_you_message', name: name.name, email: invitee_email)
  end

  def unique_invitee?
    invitee.nil? && Account.where(email: invitee_email).empty?
  end
end
