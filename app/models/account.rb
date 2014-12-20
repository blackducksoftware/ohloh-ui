class Account < ActiveRecord::Base
  attr_accessor :password, :current_password, :validate_current_password, :twitter_account, :invite_code,
                :no_email, :password_confirmation, :about_raw, :email_confirmation
  include AffiliationValidation

  DEFAULT_LEVEL = 0
  ADMIN_LEVEL   = 10
  DISABLE_LEVEL = -10
  SPAMMER_LEVEL = -20

  oh_delegators :stack_core, :project_core, :position_core

  validates :email, presence: :true, length: { in: 3..100 }, uniqueness: { case_sensitive: false },
                    confirmation: true, email_format: true, allow_blank: false
  validates :email_confirmation, email_format: true, presence: true, allow_blank: false, on: :create
  validates :password, :password_confirmation, presence: true, length: { in: 5..40 }, confirmation: true
  validates :url, length: { maximum: 100 }, url_format: true, allow_blank: true
  validates :login, presence: true, length: { in: 3..40 }, uniqueness: { case_sensitive: false }, allow_blank: false
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

  before_validation { Account::Observer.new(self).before_validation }
  before_save { Account::Observer.new(self).before_save unless password.blank? }
  after_save { Account::Observer.new(self).after_save }
  before_create { Account::Observer.new(self).before_create }
  after_create { Account::Observer.new(self).after_create }
  after_update { Account::Observer.new(self).after_update }
  before_destroy { Account::Observer.new(self).before_destroy }
  after_destroy { Account::Observer.new(self).after_destroy }

  def admin?
    level == ADMIN_LEVEL
  end

  def disabled?
    level < DEFAULT_LEVEL
  end

  def activated?
    activated_at != nil
  end

  def about_raw
    markup.raw
  end

  def about_raw=(value)
    about_markup_id.nil? ? build_markup(raw: value) : markup.raw = value
  end

  class << self
    def fetch_by_login_or_email(user_name)
      Account.where { login.eq(user_name) | email.eq(user_name) }.take
    end

    def find_or_create_anonymous_account
      anonymous_account = Account.find_by(name: 'Anonymous Coward')

      return anonymous_account if anonymous_account

      anonymous_account = Account.create(name: 'Anonymous Coward', email: 'anon@openhub.net',
                                         login: 'anonymous_coward', password: 'mailpass',
                                         password_confirmation: 'mailpass', no_email: true)
      Account::Authorize.new(anonymous_account).activate!(nil)
      anonymous_account
    end
  end
end
