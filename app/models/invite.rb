# frozen_string_literal: true

class Invite < ApplicationRecord
  include OnBehalf
  belongs_to :project, optional: true
  belongs_to :name, optional: true
  belongs_to :contribution, optional: true

  after_initialize :set_project_id_name_id

  validates :contribution, presence: true
  validate :unique_invitee_wrt_contribution
  validate :duplicate_invitee_email
  validate :account_already_exists

  def set_project_id_name_id
    return if contribution_id.nil?

    self.project_id ||= contribution_id >> 32
    self.name_id ||= contribution_id & 0x7FFFFFFF
  end

  def success_flash
    I18n.t('invites.thank_you_message', name: name.name, email: invitee_email)
  end

  def claim_url
    "http://#{ENV['URL_HOST']}/p/#{project_id}/contributors/#{contribution_id}?invite=#{activation_code}"
  end

  private

  def unique_invitee_wrt_contribution
    return true if errors[:send_limit].any?

    errors.add(:invitee_email, I18n.t('invites.invited_to_claim')) if previous_invitee_wrt_contribution.count.positive?
  end

  def duplicate_invitee_email
    return true unless invitee.nil?

    invites = Invite.where(invitee_email: invitee_email, invitor_id: invitor_id)
    invites = invites.where.not(id: id) if id
    errors.add(:invitee_email, I18n.t('invites.invited_to_join')) if invites.count.positive?
  end

  def account_already_exists
    return true unless invitee.nil?

    accounts = Account.where(email: invitee_email)
    errors.add(:invitee_email, I18n.t('invites.invited_to_join')) if accounts.count.positive?
  end

  def previous_invitee_wrt_contribution
    invites = Invite.where(invitee_email: invitee_email, contribution_id: contribution_id)
    invites = invites.where.not(id: id) if id
    invites
  end
end
