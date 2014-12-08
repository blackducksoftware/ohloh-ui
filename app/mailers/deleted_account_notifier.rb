class DeletedAccountNotifier < ActionMailer::Base
  def deletion(account)
    recipient  = SECURE_TREE['deleted_account_recipient'] || 'openhub_admins@blackducksoftware.com'
    @affiliation = get_org_name(account)
    @claimed_projects = get_project_names(account)
    @account = account
    mail(to: recipient, subject: 'Open Hub account deleted', from: 'mailer@openhub.net',
         template_path: 'mailers', template_name: 'account_deletion_notification')
  end

  protected

  def get_org_name(_account)
    'Static Data -- BlackDuck Software Inc.'
    # TODO: Fix it when integrating accounts & organization
    # return if account.organization_id.nil?
    # o = Organization.connection.select_one <<-SQL
    #   SELECT name FROM organizations WHERE id = #{account.organization_id}
    # SQL
    # o['name']
  end

  def get_project_names(_account)
    ['Static Project 1', 'Static Project 2']
    # TODO: Fix it when integrating accounts & organization
    # pids = account.claimed_project_ids.join(',')
    # return if pids.blank?
    # projs = Project.connection.select_one <<-SQL
    #   SELECT string_agg(name, ', ') AS names FROM projects WHERE id IN (#{pids})
    # SQL
    # projs['names']
  end
end
