class DeletedAccount < ActiveRecord::Base
  validates :login, :email, presence: true
  after_create :notify_admin

  REASONS_MAP = {
    1 => I18n.t('deleted_account.reason_1'),
    2 => I18n.t('deleted_account.reason_2'),
    3 => I18n.t('deleted_account.reason_3'),
    4 => I18n.t('deleted_account.reason_4'),
    5 => I18n.t('deleted_account.reason_5'),
    6 => I18n.t('deleted_account.reason_6')
  }

  def self.find_deleted_account(login)
    where(login: login).order(created_at: :desc).take
  end

  def feedback_time_elapsed?
    created_at < Time.now.utc - 1.hour
  end

  private

  def notify_admin
    DeletedAccountNotifier.deletion(self).deliver
  end
end
