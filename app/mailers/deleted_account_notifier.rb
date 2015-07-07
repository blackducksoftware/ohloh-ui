class DeletedAccountNotifier < ActionMailer::Base
  def deletion(account)
    recipient  = ENV['DELETED_ACCOUNT_RECIPIENT']
    @affiliation = get_org_name(account)
    @claimed_projects = get_project_names(account)
    @account = account
    mail(to: recipient, subject: 'Open Hub account deleted', from: 'mailer@openhub.net',
         template_path: 'mailers', template_name: 'account_deletion_notification')
  end

  protected

  def get_org_name(account)
    return if account.organization_id.nil?
    Organization.where(id: account.organization_id).first.try(:name)
  end

  def get_project_names(account)
    pids = account.claimed_project_ids
    return if pids.blank?
    Project.select("string_agg(name, ', ') AS names").where(id: pids).first['names']
  end
end
