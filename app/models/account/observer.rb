class Account::Observer
  def initialize(account)
    @account = account
  end

  def before_validation
    @account.name = @account.login if @account.name.blank?
    [:name, :email, :login, :invite_code, :twitter_account].each do |attr|
      @account.send(attr).try(:strip!)
    end
  end

  def before_create
    @account.activation_code = SecureRandom.hex(20)
  end

  def after_create
    manage_invite

    is_spam = Account::Authorize.new(@account).spam?

    Person.create!(account_id: @account.id, effective_name: @account.name) unless is_spam

    # TODO: AccountNotifier
    # AccountNotifier.deliver_signup_notification(@account) if @account.no_email
    # rescue Net::SMTPSyntaxError => e
    # if e.to_s.include?('Bad recipient address syntax')
    # @account.errors.add(:email, I18n.t('invalid_email_address')
    # raise ActiveRecord::Rollback
    # end
  end

  def before_save
    encrypt_salt_and_password
    @account.email_md5 = Digest::MD5.hexdigest(@account.email.downcase).to_s
  end

  def after_save
    # TODO: searchable
    # @account.person.reindex

    @account.person.update_attribute(:effective_name, @account.name) if @account.person

    # AccountNotifier.deliver_activation(@account) if @account.no_email
  end

  def after_update
    schedule_orgs_analysis if @account.organization_id_changed?
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

  def after_destroy
    # @account.organization.try(:schedule_analysis)
  end

  private

  def schedule_orgs_analysis
    # TODO: organization
    # previous_orgs = Organization.find_by(id: @account.organization_id_was)
    # previous_orgs.try(:schedule_analysis)
    # @account.organization.try(:schedule_analysis)
  end

  def manage_invite
    invite = Invite.find_by(activation_code: @account.invite_code) if @account.invite_code.present?

    return unless invite

    invite.update_attributes!(invitee_id: @account.id, activated_at: Time.now.utc)
    Account::Authorize.new(@account).activate!(@account.invite_code) if invite.invitee_email.eql?(@account.email)
  end

  def dependent_destroy
    [:positions, :sent_kudos, :stacks, :ratings, :reviews, :api_keys].each { |assoc| @account.send(assoc).destroy_all }
  end

  def create_deleted_account
    attrs = { login: @account.login, email: @account.email, organization_id: @account.organization_id }
    pids = @account.positions.select('array_agg(project_id) as pids').take.pids
    attrs[:claimed_project_ids] = pids if pids
    DeletedAccount.create(attrs)
  end

  def encrypt_salt_and_password
    @account.salt = Account::Authenticate.encrypt(Time.now.to_s, @account.login) unless @account.persisted?
    @account.crypted_password = Account::Authenticate.encrypt(@account.password, @account.salt)
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
