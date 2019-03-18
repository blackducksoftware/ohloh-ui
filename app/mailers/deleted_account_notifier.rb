class DeletedAccountNotifier < ActionMailer::Base
  def deletion(account)
    recipient = ENV['DELETED_ACCOUNT_RECIPIENT']
    @affiliation = organization_name(account)
    @claimed_projects = project_names(account)
    @account = account
    mail(to: recipient, subject: 'Open Hub account deleted', from: 'mailer@openhub.net',
         template_path: 'mailers', template_name: 'account_deletion_notification')
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
