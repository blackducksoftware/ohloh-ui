# frozen_string_literal: true

class DeletedAccount < ApplicationRecord
  validates :login, :email, presence: true
  after_create :notify_admin

  REASONS_MAP = {
    1 => I18n.t('deleted_account.reason_1'),
    2 => I18n.t('deleted_account.reason_2'),
    3 => I18n.t('deleted_account.reason_3'),
    4 => I18n.t('deleted_account.reason_4'),
    5 => I18n.t('deleted_account.reason_5'),
    6 => I18n.t('deleted_account.reason_6')
  }.freeze

  def self.find_deleted_account(login)
    where(login: login).order(created_at: :desc).first
  end

  def to_param
    login
  end

  def feedback_time_elapsed?
    created_at < Time.current - 1.hour
  end

  private

  def notify_admin
    mail = DeletedAccountNotifierMailer.deletion(self)
    mail.respond_to?(:deliver_now) ? mail.deliver_now : mail.deliver
  end
end
