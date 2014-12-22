class Account < ActiveRecord::Base
  include AffiliationValidation

  attr_accessor :password, :current_password, :validate_current_password, :twitter_account, :invite_code,
                :password_confirmation, :about_raw, :email_confirmation

  oh_delegators :stack_core, :project_core, :position_core
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
                    allow_blank: false, format: { with: /\A[a-zA-Z][\w-]{2,30}\Z/ }, if: :login_changed?
  validates :twitter_account, length: { maximum: 15 }, allow_blank: true
  validates :name, length: { maximum: 50 }, allow_blank: true

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
  belongs_to :best_vita, :foreign_key => 'best_vita_id', :class_name => 'Vita'

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

  scope :sort_by_relevant, lambda {|query|
    order("COALESCE( NULLIF( POSITION('#{query}' in lower(login)), 0), 100), CHAR_LENGTH(login)")
  }

  def about_raw
    markup.raw
  end

  def about_raw=(value)
    about_markup_id.nil? ? build_markup(raw: value) : markup.raw = value
  end

  def is_anonymous?
    login == AnonymousAccount::LOGIN
  end

  class << self
    def fetch_by_login_or_email(user_name)
      Account.where { login.eq(user_name) | email.eq(user_name) }.take
    end

    def simple_search(query = '')
      where { sift :name_or_login_like, query }.sort_by_relevant(query).limit(10)
    end

    def recently_active
      joins{[vitas.vita_fact, best_vita]}
        .where{name_facts.last_checkin < 1.month.ago}
        .order{coalesce(name_facts.thirty_day_commits,0).desc}
        .limit(10)
    end

    def find_or_create_anonymous_account
      Account.find_by(login: AnonymousAccount::LOGIN) || AnonymousAccount.create!
    end
  end
end
