class Account < ActiveRecord::Base
  attr_accessor :password, :current_password, :validate_current_password, :twitter_account, :invite_code,
                :no_email, :password_confirmation
  DEFAULT_LEVEL = 0
  ADMIN_LEVEL   = 10
  DISABLE_LEVEL = -10
  SPAMMER_LEVEL = -20

  oh_delegators :stack_extension, :organization_extension, :project_extension, :positions_core

  before_validation { Account::Observer.new(self).before_validation }
  before_save { Account::Observer.new(self).before_save unless password.blank? }
  after_save { Account::Observer.new(self).after_save }
  before_create { Account::Observer.new(self).before_create }
  after_create { Account::Observer.new(self).after_create }
  after_update { Account::Observer.new(self).after_update }
  before_destroy { Account::Observer.new(self).before_destroy }
  after_destroy { Account::Observer.new(self).after_destroy }

  has_many :api_keys
  has_many :actions
  has_many :kudos
  has_many :sent_kudos, class_name: :Kudo, foreign_key: :sender_id
  belongs_to :organization
  has_one :person
  has_many :topics
  has_many :ratings
  has_many :reviews
  has_many :posts
  has_many :invites, class_name: 'Invite', foreign_key: 'invitor_id'

  def admin?
    level == ADMIN_LEVEL
  end

  def disabled?
    level < DEFAULT_LEVEL
  end

  def activated?
    activated_at != nil
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
