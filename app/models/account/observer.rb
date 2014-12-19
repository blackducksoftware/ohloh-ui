class Account::Observer

  def initialize(account)
    @account = account
  end

  def before_validation
    @account.name = @account.login if @account.name.blank?
    [:name, :email, :email_confirmation, :login, :invite_code, :twitter_account].each{|attr| @account.send(attr).try(:strip!) }
  end

  def before_create
    @account.activation_code = SecureRandom.hex(20)
  end

  def after_create
    manage_invite if @account.invite_code.present?

    Person.create!(account_id: @account.id, effective_name: @account.name) unless @account.authorization.spam?

    AccountNotifier.deliver_signup_notification(@account) if @account.no_email
  rescue Net::SMTPSyntaxError => e
    if e.to_s.include?('Bad recipient address syntax')
      @account.errors.add(:email, "The Black Duck Open Hub could not send registration email to <strong class='red'>#{@account.email}</strong>. Invalid Email Address provided.")
      raise ActiveRecord::Rollback
    end
  end

  def before_Save
    return if @account.password.blank?
    @account.salt = Account::Authenticator.encrypt(Time.now.to_s, @account.login) unless @account.persisted?
    @account.crypted_password = Account::Authenticator.encrypt(@account.password, @account.salt)
    @account.email_md5 = Digest::MD5.hexdigest(@account.email.downcase).to_s
  end

  def after_save
    # TODO: searchable
    # @account.person.reindex

		@account.person.try(update_attribute(:effective_name, @account.name))

    AccountNotifier.deliver_activation(@account) if @account.no_email
  end

  def after_update
    schedule_orgs_analysis if @account.organization_id_changed?
    if @account.authorization.spam?
      #TODO: acts_as_editable, posts, manage
      # posts.each{|post| post.destroy_and_cleanup }
      # all_manages.each{|manage| manage.destroy_by!(@account) }
      # @account.edits.each{|edit| edit.undo rescue if edit.undone? }
      @account.topics.where{posts_count.eq(0)}.destroy_all
      @account.person.try(:destroy)
      dependent_destroy
    end
  rescue
    raise ActiveRecord::Rollback
  end

  def before_destroy
    create_assoc_deleted_account

    dependent_destroy

    @account.posts.update_all(account_id: anonymous_account)
    @account.account_reports.update_all(account_id: anonymous_account)
    @account.topics.update_all(account_id: anonymous_account)
    @account.edits.update_all(account_id: anonymous_account)

    Edit.where( undone_by: @account ).update_all(undone_by: anonymous_account)
    Invite.where{ invitor_id.eq(@account) | invitee_id.eq(@account) }
      .update_all(invitor_id: anonymous_account, invitee_id: anonymous_account)
    Manage.where{ approved_by.eq(@account) | deleted_by.eq(@account) }
      .update_all(approved_by: anonymous_account, deleted_by: anonymous_account)
  end

  def after_destroy
    @account.organization.try(:schedule_analysis)
  end

  private

  def schedule_orgs_analysis
    previous_orgs = Organization.find_by(id: @account.organization_id_was)
    previous_orgs.try(:schedule_analysis)
    @account.organization.try(:schedule_analysis)
  end

  def manage_invite
    invite = Invite.find_by(activation_code: @account.invite_code)
    if invite
      invite.update_attributes!(invitee_id: @account.id, activated_at: Time.now.utc)
      @account.authorization.activate!(@account.invite_code) if invite.invitee_email.eql?(@account.email)
    end
  end

  def dependent_destroy
    [:positions, :sent_kudos, :stacks, :ratings, :reviews, :api_keys].each{|assoc| @account.send(assoc).destroy_all}
  end

  def create_assoc_deleted_account
    attrs = { login: @account.login, email: @account.email, organization_id: @account.organization_id }
    pids = @account.positions.select{  array_agg(project_id).as(pids) }.take.pids
    attrs[:claimed_project_ids] = pids if pids
    DeletedAccount.create(attrs)
  end
end
