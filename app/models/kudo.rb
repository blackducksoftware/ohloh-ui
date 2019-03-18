class Kudo < ActiveRecord::Base
  belongs_to :sender, foreign_key: :sender_id, class_name: 'Account'
  belongs_to :account
  belongs_to :project
  belongs_to :name
  has_one :name_fact, foreign_key: :name_id, primary_key: :name_id

  scope :recent, ->(limit = 3) { limit(limit) }

  before_validation :assign_account_from_position
  validates :message, length: 0..80, allow_nil: true
  validate :cant_kudo_self

  after_save :notify_recipient

  def person
    (account_id && Person.find_by(account_id: account_id)) || Person.find_by(name_id: name_id, project_id: project_id)
  end

  def person_name
    (name && name.name) || account.name
  end

  class << self
    def sort_by_created_at
      select(attribute_names)
        .select("#{max_created_at_per_account} AS sort_time")
        .order('sort_time DESC, project_id DESC')
        .readonly
    end

    def find_for_sender_and_target(sender, target)
      case target
      when Account
        Kudo.find_by(sender_id: sender.id, account_id: target.id)
      when Contribution, Person
        target = target.account || target.contributions.first if target.is_a?(Person)
        Kudo.find_by(sender_id: sender.id, project_id: target.project_id, name_id: target.name_fact.name_id)
      else
        raise 'Uknown Target Type'
      end
    end

    private

    def max_created_at_per_account
      "
      CASE WHEN kudos.account_id IS NULL THEN
        kudos.created_at
      ELSE (
        SELECT MAX(same_account_kudos.created_at)
          FROM kudos AS same_account_kudos
          WHERE same_account_kudos.sender_id = kudos.sender_id
            AND same_account_kudos.account_id = kudos.account_id
        )
      END"
    end
  end

  private

  def assign_account_from_position
    return unless project_id && name_id

    position = Position.find_by(project_id: project_id, name_id: name_id)
    self.account_id = (position && position.account_id)
  end

  def cant_kudo_self
    return unless sender_id == account_id

    errors.add :base, I18n.t('kudos.cant_kudo_self')
  end

  def notify_recipient
    return unless errors.empty? && account && account.email_kudos?

    AccountMailer.kudo_recipient(self).deliver_now
  end
end
