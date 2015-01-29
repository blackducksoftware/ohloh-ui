class Invite < ActiveRecord::Base

  include OnBehalf
  belongs_to :project
  belongs_to :name
  belongs_to :contribution

  # TO-DO: once contribution implemented, uncomment it
  #validates :contribution, presence: true
  validates :invitee_email, uniqueness: { scope: [:contribution_id], message: I18n.t('invites.already_invited_to_claim')}
  validates :invitee_email, uniqueness: { if: proc { |i| i.invitee.nil? && Account.find_by_email(i.invitee_email).nil? },
                                          message: I18n.t('invites.already_invited_to_join')}

  before_save :set_project_id_name_id

  def set_project_id_name_id
    self.project_id ||= self.contribution_id >> 32
    self.name_id ||= self.contribution_id & 0x7FFFFFFF
  end

  def success_flash
    I18n.t('invites.thank_you_message', name: self.name.name, email: self.invitee_email)
  end

end
