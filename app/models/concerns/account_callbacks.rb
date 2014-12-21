module AccountCallbacks
  extend ActiveSupport::Concern

  included do
    before_validation :set_name_to_login, if: -> { name.blank? }
    before_create :set_activation_code_to_random_hash
    before_create :encrypt_salt
    before_save :encrypt_email, if: :email_changed?
    before_save :encrypt_password, if: -> { password.present? }
    before_destroy :dependent_destroy, :create_deleted_account,
                   :transfer_associations_to_anonymous_account

    after_create :activate_using_invite!, if: -> { invite_code.present? }
    after_create :create_person!, unless: -> { Account::Authorize.new(self).spam? }
    after_update :destroy_spammer_dependencies, if: -> { Account::Authorize.new(self).spam? }
    # FIXME: organization
    # after_update :schedule_previous_organization_analysis,
    #              :schedule_organization_analysis, if: :organization_id_changed?
    # after_destroy :schedule_organization_analysis
    # FIXME: Implement alongwith AccountNotifier
    # after_create :deliver_signup_notification, if: :no_email
    # after_save :deliver_activation, unless: :no_email
    # FIXME: Integrate alongwith searchable
    # after_save :reindex_person, if: :person
    after_save :update_person_effective_name, if: -> { name_changed? && person.present? }
  end

  private

  def create_person!
    Person.create!(account_id: id, effective_name: name)
  end

  def update_person_effective_name
    person.update!(effective_name: name)
  end

  def reindex_person
    person.reindex
  end

  def activate_using_invite!
    invite = Invite.find_by(activation_code: invite_code)
    return unless invite

    invite.update!(invitee_id: id, activated_at: Time.now.utc)
    Account::Authorize.new(self).activate!(invite_code) if invite.invitee_email.eql?(email)
  end

  def set_name_to_login
    self.name = login
  end

  def encrypt_email
    self.email_md5 = Digest::MD5.hexdigest(email.downcase).to_s
  end

  def encrypt_salt
    self.salt = Account::Authenticate.encrypt(Time.now.to_s, login)
  end

  def encrypt_password
    self.crypted_password = Account::Authenticate.encrypt(password, salt)
  end

  def set_activation_code_to_random_hash
    self.activation_code = SecureRandom.hex(20)
  end

  def deliver_signup_notification
    AccountNotifier.deliver_signup_notification(self)
  rescue Net::SMTPSyntaxError => e
    if e.to_s.include?('Bad recipient address syntax')
      errors.add(:email, I18n.t('invalid_email_address'))
      raise ActiveRecord::Rollback
    end
  end

  def deliver_activation
    AccountNotifier.deliver_activation(self)
  end

  def schedule_previous_organization_analysis
    previous_organization = Organization.find_by(id: organization_id_was)
    previous_organization.try(:schedule_analysis)
  end

  def schedule_organization_analysis
    organization.try(:schedule_analysis)
  end

  def destroy_spammer_dependencies
    # FIXME: acts_as_editable, posts, manage
    # posts.each { |post| post.destroy_and_cleanup }
    # all_manages.each { |manage| manage.destroy_by!(self) }
    # edits.each { |edit| edit.undo rescue if edit.undone? }
    topics.where(posts_count: 0).destroy_all
    person.try(:destroy)
    dependent_destroy
  rescue
    raise ActiveRecord::Rollback
  end

  def dependent_destroy
    %w(positions sent_kudos stacks ratings reviews api_keys).each do |association|
      send(association).destroy_all
    end
  end

  def create_deleted_account
    traits = { login: login, email: email, organization_id: organization_id }
    pids = positions.select('array_agg(project_id) as pids').take.pids
    traits[:claimed_project_ids] = pids if pids
    DeletedAccount.create(traits)
  end

  def transfer_associations_to_anonymous_account
    @anonymous_account = Account.find_or_create_anonymous_account
    posts.update_all(account_id: @anonymous_account)
    # account_reports.update_all(account_id: @anonymous_account)
    topics.update_all(account_id: @anonymous_account)
    # edits.update_all(account_id: @anonymous_account)
    # update_edit
    update_invite
    update_manage
  end

  def update_invite
    Invite.where { invitor_id.eq(id) | invitee_id.eq(id) }
      .update_all(invitor_id: @anonymous_account, invitee_id: @anonymous_account)
  end

  def update_manage
    Manage.where { approved_by.eq(id) | deleted_by.eq(id) }
      .update_all(approved_by: @anonymous_account, deleted_by: @anonymous_account)
  end

  def update_edit
    Edit.where(undone_by: self).update_all(undone_by: @anonymous_account)
  end
end
