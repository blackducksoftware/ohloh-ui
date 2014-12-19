class Account < ActiveRecord::Base
  include AffiliationValidation

  DEFAULT_LEVEL = 0
  ADMIN_LEVEL   = 10
  DISABLE_LEVEL = -10
  SPAMMER_LEVEL = -20

  oh_delegators :stack_core, :project_core, :positions_core
  attr_accessor :email_confirmation, :password, :password_confirmation, :about_raw

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
end
