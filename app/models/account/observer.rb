class Account::Observer
  def initialize(account)
    @account = account
  end

  def after_update
    if Account::Authorize.new(@account).spam?
      # TODO: acts_as_editable, posts, manage
      # posts.each { |post| post.destroy_and_cleanup }
      # all_manages.each { |manage| manage.destroy_by!(@account) }
      # @account.edits.each { |edit| edit.undo rescue if edit.undone? }
      @account.topics.where(posts_count: 0).destroy_all
      @account.person.try(:destroy)
      dependent_destroy
    end
  rescue
    raise ActiveRecord::Rollback
  end

  def before_destroy
    create_deleted_account
    dependent_destroy
    transfer_associations_to_anonymous_account
  end

  private

  def dependent_destroy
    [:positions, :sent_kudos, :stacks, :ratings, :reviews, :api_keys].each { |assoc| @account.send(assoc).destroy_all }
  end

  def create_deleted_account
    attrs = { login: @account.login, email: @account.email, organization_id: @account.organization_id }
    pids = @account.positions.select('array_agg(project_id) as pids').take.pids
    attrs[:claimed_project_ids] = pids if pids
    DeletedAccount.create(attrs)
  end

  def transfer_associations_to_anonymous_account
    @anonymous_account = Account.find_or_create_anonymous_account
    @account.posts.update_all(account_id: @anonymous_account)
    # @account.account_reports.update_all(account_id: @anonymous_account)
    @account.topics.update_all(account_id: @anonymous_account)
    # @account.edits.update_all(account_id: @anonymous_account)
    # update_edit
    update_invite
    update_manage
  end

  def update_invite
    Invite.where { invitor_id.eq(@account) | invitee_id.eq(@account) }
      .update_all(invitor_id: @anonymous_account, invitee_id: @anonymous_account)
  end

  def update_manage
    Manage.where { approved_by.eq(@account) | deleted_by.eq(@account) }
      .update_all(approved_by: @anonymous_account, deleted_by: @anonymous_account)
  end

  def update_edit
    Edit.where(undone_by: @account).update_all(undone_by: @anonymous_account)
  end
end
