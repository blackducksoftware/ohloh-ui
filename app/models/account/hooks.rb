class Account::Hooks
  def before_validation(account)
    assign_name_to_login(account) if account.name.blank?
  end

  def before_destroy(account)
    dependent_destroy(account)
    create_deleted_account(account)
    transfer_associations_to_anonymous_account(account)
  end

  def after_create(account)
    activate_using_invite!(account) if account.invite_code.present?
    create_person!(account) unless Account::Access.new(account).spam?
    # FIXME: Implement alongwith AccountNotifier
    # deliver_signup_notification(account) unless account.anonymous?
  end

  def after_update(account)
    destroy_spammer_dependencies(account) if Account::Access.new(account).spam?
    # FIXME: organization
    # if account.organization_id_changed?
    #   schedule_organization_analysis(account.organization_id_was)
    #   schedule_organization_analysis(account.organization_id)
    # end
  end

  def after_destroy(_account)
    # FIXME: organization
    # schedule_organization_analysis(account.organization_id)
  end

  def after_save(account)
    # FIXME: Implement alongwith AccountNotifier
    # deliver_activation(account) unless account.anonymous?
    # FIXME: Integrate alongwith searchable
    # reindex_person(account) if account.person && !Account::Access.new(account).spam?
    update_person_effective_name(account) if account.person.present? && !Account::Access.new(account).spam?
  end

  private

  def create_person!(account)
    Person.create!(account_id: account.id, effective_name: account.name)
  end

  def update_person_effective_name(account)
    account.person.update!(effective_name: account.name)
  end

  def reindex_person(account)
    account.person.reindex
  end

  def activate_using_invite!(account)
    invite = Invite.find_by(activation_code: account.invite_code)
    return unless invite

    invite.update!(invitee_id: account.id, activated_at: Time.now.utc)

    Account::Access.new(account).activate!(account.invite_code) if invite.invitee_email.eql?(account.email)
  end

  def assign_name_to_login(account)
    account.name = account.login
  end

  def deliver_signup_notification(account)
    AccountNotifier.deliver_signup_notification(account)
  rescue Net::SMTPSyntaxError => e
    if e.to_s.include?('Bad recipient address syntax')
      account.errors.add(:email, I18n.t('invalid_email_address'))
      raise ActiveRecord::Rollback
    end
  end

  def deliver_activation(account)
    AccountNotifier.deliver_activation(account)
  end

  def schedule_organization_analysis(organization_id)
    Organization.find_by_id(organization_id).try(:schedule_analysis)
  end

  def destroy_spammer_dependencies(account)
    # FIXME: acts_as_editable, posts, manage
    # account.posts.each { |post| post.destroy_and_cleanup }
    # account.all_manages.each { |manage| manage.destroy_by!(account) }
    # account.edits.each { |edit| edit.undo rescue if edit.undone? }
    account.topics.where(posts_count: 0).destroy_all
    account.person.try(:destroy)
    dependent_destroy(account)
  rescue
    raise ActiveRecord::Rollback
  end

  def dependent_destroy(account)
    %w(positions sent_kudos stacks ratings reviews api_keys).each do |association|
      account.send(association).destroy_all
    end
  end

  def create_deleted_account(account)
    traits = { login: account.login, email: account.email,
               organization_id: account.organization_id }
    pids = account.positions.select('array_agg(project_id) as pids').take.pids
    traits[:claimed_project_ids] = pids if pids
    DeletedAccount.create(traits)
  end

  def transfer_associations_to_anonymous_account(account)
    @anonymous_account = Account.find_or_create_anonymous_account
    account.posts.update_all(account_id: @anonymous_account)
    # account.account_reports.update_all(account_id: @anonymous_account)
    account.topics.update_all(account_id: @anonymous_account)
    # account.edits.update_all(account_id: @anonymous_account)
    # update_edit(account.id)
    update_invite(account.id)
    update_manage(account.id)
  end

  def update_invite(account_id)
    Invite.where { invitor_id.eq(account_id) | invitee_id.eq(account_id) }
      .update_all(invitor_id: @anonymous_account, invitee_id: @anonymous_account)
  end

  def update_manage(account_id)
    Manage.where { approved_by.eq(account_id) | deleted_by.eq(account_id) }
      .update_all(approved_by: @anonymous_account, deleted_by: @anonymous_account)
  end

  def update_edit(account_id)
    Edit.where(undone_by: account_id).update_all(undone_by: @anonymous_account)
  end
end
