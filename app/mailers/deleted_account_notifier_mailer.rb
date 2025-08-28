# frozen_string_literal: true

class DeletedAccountNotifierMailer < ApplicationMailer
  def deletion(account)
    recipient = ENV.fetch('DELETED_ACCOUNT_RECIPIENT', nil)
    @affiliation = organization_name(account)
    @claimed_projects = project_names(account)
    @account = account
    mail(
      to: recipient,
      subject: I18n.t('mailers.deleted_account_notifier_mailer.account_deleted'),
      from: 'mailer@openhub.net',
      template_path: 'mailers', template_name: 'account_deletion_notification'
    )
  end

  protected

  def organization_name(account)
    Organization.find_by(id: account.organization_id).try(:name) if account.organization_id
  end

  def project_names(account)
    pids = account.claimed_project_ids
    return if pids.blank?

    Project.where(id: pids).map(&:name).join(', ')
  end
end
