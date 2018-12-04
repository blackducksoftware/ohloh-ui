# rubocop:disable Metrics/ClassLength

class Account::Hooks
  def before_validation(account)
    assign_name_to_login(account) if account.name.blank?
    account.organization_name = nil unless account.affiliation_type_other?
    account.organization_id = nil if account.affiliation_type_other?
  end

  def before_destroy(account)
    dependent_destroy(account)
    account.verifications.destroy_all
    create_deleted_account(account)
    transfer_topics_replied_by_to_anonymous_account(account)
    transfer_associations_to_anonymous_account(account)
  end

  def after_create(account)
    account.password = nil
    account.current_password = nil
    activate_using_invite!(account) if account.invite_code.present?
    create_person!(account) unless account.access.spam?
    deliver_signup_notification(account) unless account.anonymous? || account.access.activated?
  end

  def after_update(account)
    destroy_spammer_dependencies(account) if account.access.spam?
    return unless account.organization_id_changed?
    schedule_organization_analysis(account.organization_id_was)
    schedule_organization_analysis(account.organization_id)
  end

  def after_destroy(account)
    schedule_organization_analysis(account.organization_id)
  end

  def after_save(account)
    update_person_effective_name(account) if account.person.present? && !account.access.spam?
  end

  private

  def create_person!(account)
    Person.create!(account_id: account.id, effective_name: account.name)
  end

  def update_person_effective_name(account)
    account.person.update!(effective_name: account.name)
  end

  def activate_using_invite!(account)
    invite = Invite.find_by(activation_code: account.invite_code)
    return unless invite

    invite.update!(invitee_id: account.id, activated_at: Time.current)

    account.access.activate!(account.activation_code) if invite.invitee_email.eql?(account.email)
  end

  def assign_name_to_login(account)
    account.name = account.login
  end

  def deliver_signup_notification(account)
    AccountMailer.signup_notification(account).deliver_now
  end

  def schedule_organization_analysis(organization_id)
    return unless organization_id
    Organization.find_by(id: organization_id).schedule_analysis
  end

  # rubocop:disable Metrics/AbcSize
  def destroy_spammer_dependencies(account)
    account.posts.each(&:destroy_with_empty_topic)
    account.all_manages.each { |manage| manage.destroy_by!(account) }
    account.edits.not_undone.each { |edit| safe_undo(edit) }
    account.topics.where(posts_count: 0).destroy_all
    account.person.try(:destroy)
    dependent_destroy(account)
  rescue
    raise ActiveRecord::Rollback
  end
  # rubocop:enable Metrics/AbcSize

  # All edits cannot be undone due to the edits order and validations
  def safe_undo(edit)
    Edit.transaction(requires_new: true) { edit.undo!(Account.hamster) if edit.allow_undo? }
  rescue
    Rails.logger.info "Spam undo failed: #{$ERROR_INFO.inspect}\n#{edit.inspect}"
  end

  def dependent_destroy(account)
    %w[positions sent_kudos stacks ratings reviews api_keys].each do |association|
      account.send(association).destroy_all
    end
  end

  def create_deleted_account(account)
    traits = { login: account.login, email: account.email, organization_id: account.organization_id }
    pids = account.positions.select('array_agg(project_id) as pids').take.pids
    traits[:claimed_project_ids] = pids if pids
    DeletedAccount.create(traits)
  end

  # rubocop:disable Rails/SkipsModelValidations # We want a quick DB update in the following methods.
  def transfer_associations_to_anonymous_account(account)
    @anonymous_account = Account.find_or_create_anonymous_account
    account.posts.update_all(account_id: @anonymous_account)
    # account.account_reports.update_all(account_id: @anonymous_account)
    account.topics.update_all(account_id: @anonymous_account)
    account.edits.update_all(account_id: @anonymous_account)
    update_edit(account.id)
    update_invite(account.id)
    update_manage(account.id)
  end

  def transfer_topics_replied_by_to_anonymous_account(account)
    @anonymous_account = Account.find_or_create_anonymous_account
    Topic.where(replied_by: account.id).update_all(replied_by: @anonymous_account.id)
  end

  def update_invite(account_id)
    invites = Invite.arel_table
    Invite.where(invites[:invitor_id].eq(account_id).or(invites[:invitee_id].eq(account_id)))
          .update_all(invitor_id: @anonymous_account, invitee_id: @anonymous_account)
  end

  def update_manage(account_id)
    manages = Manage.arel_table
    Manage.where(manages[:approved_by].eq(account_id).or(manages[:deleted_by].eq(account_id)))
          .update_all(approved_by: @anonymous_account, deleted_by: @anonymous_account)
  end

  def update_edit(account_id)
    Edit.where(undone_by: account_id).update_all(undone_by: @anonymous_account)
  end
end
