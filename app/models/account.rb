class Account < ActiveRecord::Base
  include AffiliationValidation

  attr_accessor :password, :current_password, :validate_current_password, :twitter_account, :invite_code,
                :password_confirmation, :about_raw, :email_confirmation
  attr_writer :ip

  oh_delegators :stack_core, :project_core, :position_core, :claim_core
  strip_attributes :name, :email, :login, :invite_code, :twitter_account

  validates :email, presence: :true, length: { in: 3..100 }, uniqueness: { case_sensitive: false },
                    confirmation: true, email_format: true, allow_blank: false
  validates :email_confirmation, email_format: true, presence: true, allow_blank: false, on: :create

  validates :password, presence: true, on: :create
  validates :password, :password_confirmation, confirmation: true, on: [:create, :update]
  validates :password, :password_confirmation, length: { in: 5..40 }, if: -> { password.present? }

  validates :url, length: { maximum: 100 }, url_format: true, allow_blank: true
  validates :login, presence: true
  validates :login, length: { in: 3..40 }, uniqueness: { case_sensitive: false },
                    allow_blank: false, format: { with: Patterns::LOGIN_FORMAT }, if: :login_changed?
  validates :twitter_account, length: { maximum: 15 }, allow_blank: true
  validates :name, length: { maximum: 50 }, allow_blank: true
  validate :valid_current_password?, on: :update, if: -> { current_password.present? }

  has_many :api_keys
  has_many :actions
  has_many :kudos
  has_many :sent_kudos, class_name: :Kudo, foreign_key: :sender_id
  belongs_to :markup, foreign_key: :about_markup_id, autosave: true, class_name: 'Markup'
  belongs_to :organization
  has_one :person
  has_many :topics
  has_many :ratings
  has_many :reviews
  has_many :posts
  has_many :invites, class_name: 'Invite', foreign_key: 'invitor_id'
  has_many :vitas
  belongs_to :best_vita, foreign_key: 'best_vita_id', class_name: 'Vita'

  before_validation Account::Hooks.new
  before_create Account::Encrypter.new
  before_save Account::Encrypter.new
  before_destroy Account::Hooks.new
  after_create Account::Hooks.new
  after_update Account::Hooks.new
  after_destroy Account::Hooks.new
  after_save Account::Hooks.new

  sifter :name_or_login_like do |query|
    name.like("%#{query}%") | login.like("%#{query}%")
  end

  scope :simple_search, lambda { |query|
    where { sift :name_or_login_like, query }
      .order("COALESCE( NULLIF( POSITION('#{query}' in lower(login)), 0), 100), CHAR_LENGTH(login)")
      .limit(10)
  }

  scope :recently_active, lambda {
    joins { [vitas.vita_fact, best_vita] }
      .where { (name_facts.last_checkin > 1.month.ago) & (best_vita_id.not_eq(nil)) }
      .order { coalesce(name_facts.thirty_day_commits, 0).desc }.limit(10)
  }

  scope :with_facts, lambda {
    joins { positions.project }
      .joins { ['INNER JOIN name_facts ON name_facts.name_id = positions.name_id'] }
      .where { positions.name_id.not_eq(nil) }
      .where { name_facts.analysis_id.eq(projects.best_analysis_id) & name_facts.type.eq('ContributorFact') }
  }

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
    urlable_login || id.to_s
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

  # Array of eligible badges or empty array
  # FIXME: Integrate alongwith Badge.
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

  private

  def urlable_login
    login.match(Patterns::LOGIN_FORMAT) && login
  end
end
