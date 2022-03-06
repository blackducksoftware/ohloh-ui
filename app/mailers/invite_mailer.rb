# frozen_string_literal: true

class InviteMailer < ApplicationMailer
  default from: 'mailer@openhub.net'
  default template_path: 'mailers'

  def send_invite(invite)
    @invite = invite
    mail to: @invite.invitee_email, subject: I18n.t('invites.fields.email_subject', name: @invite.invitor.name)
  end
end
