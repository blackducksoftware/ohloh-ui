class ApiKey < ActiveRecord::Base
  DEFAULT_DAILY_LIMIT = 1000
  STATUS_OK = 0
  STATUS_LIMIT_EXCEEDED = 1
  STATUS_DISABLED = 2
  KEY_LIMIT_PER_ACCOUNT = 10

  belongs_to :account
  belongs_to :oauth_application, class_name: 'Doorkeeper::Application', dependent: :destroy

  after_initialize :defaults

  accepts_nested_attributes_for :oauth_application

  validates :description, length: { within: 4..2000 }
  validates :terms, acceptance: { accept: '1', message: I18n.t(:must_accept_terms) }

  filterable_by ['accounts.name', 'oauth_applications.uid', 'api_keys.description',
                 'oauth_applications.name']

  scope :in_good_standing, -> { where.not(status: STATUS_DISABLED) }
  scope :by_account_name, -> { joins(:account).order('lower(accounts.name)') }
  scope :by_newest, -> { order(created_at: :desc) }
  scope :by_oldest, -> { order(created_at: :asc) }
  scope :by_most_requests_today, -> { order(daily_count: :desc) }
  scope :by_most_requests, -> { order(total_count: :desc) }
  scope :by_most_recent_request, -> { order("COALESCE(api_keys.last_access_at,'1970-01-01') desc") }

  def defaults
    self.daily_limit ||= DEFAULT_DAILY_LIMIT
  end

  def may_i_have_another?
    now = Time.current
    daily_reset!
    update_attributes!(last_access_at: now,
                       day_began_at: day_began_at || now,
                       daily_count: daily_count + 1,
                       total_count: total_count + 1,
                       status: exceeded_daily_allotment? ? STATUS_LIMIT_EXCEEDED : status)
    status == STATUS_OK
  end

  class << self
    def reset_all!
      ApiKey.update_all(daily_count: 0, day_began_at: Time.current)
      ApiKey.where(status: STATUS_LIMIT_EXCEEDED).update_all(status: STATUS_OK)
    end

    def find_by_oauth_application_uid(client_id)
      joins(:oauth_application).where('oauth_applications.uid' => client_id).first
    end
  end

  private

  def daily_reset!
    return unless day_began_at && day_began_at < (Time.current - 1.day)
    assign_attributes(day_began_at: Time.current,
                      daily_count: 0,
                      status: (status == STATUS_LIMIT_EXCEEDED) ? STATUS_OK : status)
  end

  def exceeded_daily_allotment?
    (daily_count >= daily_limit) && status == STATUS_OK
  end
end
