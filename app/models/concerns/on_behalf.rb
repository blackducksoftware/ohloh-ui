module OnBehalf
  extend ActiveSupport::Concern

  MAX_RECEIVED = 5
  MAX_SENT = 50

  included do
    belongs_to :invitor, class_name: 'Account', foreign_key: 'invitor_id'
    belongs_to :invitee, class_name: 'Account', foreign_key: 'invitee_id'

    validates :invitor, presence: true
    validates :invitee_email, presence: { message: I18n.t('invites.invitee_email_blank') }
    validates :invitee_email, length: { in: 3..100 }, email_format: true, allow_blank: true

    validate :email_threshold_max_received
    validate :email_threshold_max_sent

    before_save :make_invitee
    before_save :make_activation_code
  end

  private

  def make_invitee
    self.invitee = Account.find_by(email: invitee_email) # okay to be nil
  end

  def make_activation_code
    self.activation_code ||= ActivationCode.generate
  end

  def email_threshold_max_received
    invites_sent_to_this_email = self.class.where(invitee_email: invitee_email).count
    err_msg = I18n.t('invites.email_sent_exceeded', name: self.class.name.pluralize.downcase, count: MAX_RECEIVED)
    errors.add(:send_limit, err_msg) if invites_sent_to_this_email >= OnBehalf::MAX_RECEIVED
  end

  def email_threshold_max_sent
    invites_sent_from_this_account = self.class.where(invitor_id: invitor_id).count
    err_msg = I18n.t('invites.account_sent_exceeded', name: self.class.name.pluralize.downcase, count: MAX_SENT)
    errors.add(:send_limit, err_msg) if invites_sent_from_this_account >= OnBehalf::MAX_SENT
  end
end
