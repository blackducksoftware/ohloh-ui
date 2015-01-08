class Account < ActiveRecord::Base
  include AffiliationValidation
  include AccountValidations
  include AccountAssociations
  include AccountScopes
  include AccountCallbacks

  attr_accessor :password, :current_password, :validate_current_password, :twitter_account, :invite_code,
                :password_confirmation, :about, :email_confirmation
  attr_writer :ip

  oh_delegators :stack_core, :project_core, :position_core, :claim_core
  strip_attributes :name, :email, :login, :invite_code, :twitter_account

  fix_string_column_encodings!

  def about_raw
    markup.raw
  end

  def about_raw=(value)
    about_markup_id.nil? ? build_markup(raw: value) : markup.raw = value
  end

  def anonymous?
    login == AnonymousAccount::LOGIN
  end

  def valid_current_password?
    authenticator = Account::Authenticator.new(login: login, password: current_password)
    return if authenticator.authenticated? && Account::Access.new(authenticator.account).active_and_not_disabled?
    errors.add(:current_password)
  end

  def to_param
    (login.match(Patterns::LOGIN_FORMAT) && login) || id.to_s
  end

  # ip is tracked as a temporary field - not saved in the db.
  # It's optional, but used if present by acts_as_editable.
  def ip
    defined?(@ip) ? @ip : '0.0.0.0'
  end

  def edit_count
    edits.where(undone: false).count
  end

  def best_vita_fact
    @best_vita_fact ||= VitaFact.where(vita_id: best_vita_id).first
  end

  def email_topics?
    email_master && email_posts
  end

  def email_kudos?
    email_master && email_kudos
  end

  # Removes old unused vitae from this account, leaving only the current best_vita
  def cleanup
    return unless id && best_vita_id
    Vita.where { account_id.eq(my { id }) & id.not_eq(best_vita_id) }.delete_all
  end

  # To speed up searching, we keep track of an account's 'aliases'.
  def update_akas
    akas = claimed_positions.includes(:name).map do |p|
      p.name.name
    end.uniq.join("\n")

    update_attribute(:akas, akas)
  end

  def run_actions(status)
    actions.where(status: status).each(&:run)
  end

  # Work around problem with has_many:
  # ActiveRecord::HasManyThroughAssociationPolymorphicError:
  #   Cannot have a has_many :through association 'Account#links' on the polymorphic object 'Target#target'.
  def links
    edits.where { target_type.eq('Link') & type.eq('CreateEdit') & undone.not_eq(true) }.pluck(:target)
  end

  def about_lines
    about.to_s.split('<br/>')
  end

  def one_line_about
    about_lines.first.to_s.strip if about.present?
  end

  def badges
    @badges ||= Badge.all_eligible(self)
  end

  def most_experienced_language
    return unless best_vita.try(:vita_fact).try(:vita_language_facts).to_a.any?
    best_vita.vita_fact.vita_language_facts.first.language
  end

  def resend_activation!
    AccountNotifier.deliver_signup_notification(self, true)
    update!(activation_resent_at: Time.now.utc)
  end

  # TODO: Replaces get_first_commit_date
  def first_commit_date
    first_checkin = best_vita.try(:vita_fact).try(:first_checkin)
    first_checkin.try(:to_date).try(:beginning_of_month)
  end

  def kudo_rank
    person.try(:kudo_rank) || 1
  end

  def symbolized_commits_by_project
    scbp = best_vita.try(:vita_fact).try(:commits_by_project)
    scbp.to_a.map(&:symbolize_keys)
  end

  def symbolized_commits_by_language
    scbp = best_vita.try(:vita_fact).try(:commits_by_language)
    scbp.to_a.map(&:symbolize_keys)
  end

  def sorted_commits_by_project
    cbp = symbolized_commits_by_project
    sorted_cbp = cbp.inject({}) do |res, hsh|
      pos_id = hsh[:position_id].to_i
      res[pos_id] ||= 0
      res[pos_id] += hsh[:commits].to_i
      res
    end.sort_by { |k, v| v }.reverse
  end

  def sorted_commits_by_language
    cbl = symbolized_commits_by_language
    sorted_cbl = cbl.inject({}) do |res, hsh|
      lang = hsh[:l_name]
      res[lang] ||= { :nice_name => hsh[:l_nice_name], :commits => 0 }
      res[lang][:commits] += hsh[:commits].to_i
      res
    end.sort_by { |k, v| v[:commits] }.reverse
  end

  class << self
    def resolve_login(login)
      Account.where { lower(login) == login.downcase }.first
    end

    def hamster
      Account.find_by_login('ohloh_slave')
    end

    def uber_data_crawler
      @uber_data_crawler ||= Account.find_by_login('uber_data_crawler')
    end

    def non_human_ids
      where(login: %w(ohloh_slave uber_data_crawler)).pluck(:id)
    end

    def fetch_by_login_or_email(user_name)
      where { login.eq(user_name) | email.eq(user_name) }.take
    end

    def find_or_create_anonymous_account
      find_by(login: AnonymousAccount::LOGIN) || AnonymousAccount.create!
    end
  end
end
