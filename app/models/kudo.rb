class Kudo < ActiveRecord::Base
  belongs_to :sender, foreign_key: :sender_id, class_name: :Account
  belongs_to :account
  belongs_to :project
  belongs_to :name

  # TODO: Replace recent_kudos.
  scope :recent, -> limit = 3 { limit(limit) }

  before_validation :assign_account_from_position
  validates :message, length: 0..255, allow_nil: true
  validate :cant_kudo_self

  def person
    (account_id && Person.find_by_account_id(account_id)) || Person.find_by_name_id_and_project_id(name_id, project_id)
  end

  def person_name
    (name && name.name) || account.name
  end

  class << self
    # TODO: Replace display_sorted with sort_by_created_at
    def sort_by_created_at
      select(attribute_names)
        .select("#{ max_created_at_per_account } AS sort_time")
        .order('sort_time DESC, project_id DESC')
        .readonly
    end

    def self.find_by_sender_and_target(sender, target)
      case target
      when Account
        Kudo.find_by_sender_id_and_account_id(sender.id, target.id)
      when Contribution, Person
        target = target.account ? target.account : target.contributions.first if target.is_a?(Person)
        Kudo.find_by_sender_id_and_project_id_and_name_id(sender.id, target.project_id, target.contributor_fact.name_id)
      else
        fail 'Uknown Target Type'
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
    position = Position.find_by_project_id_and_name_id(project_id, name_id)
    self.account_id = (position && position.account_id)
  end

  def cant_kudo_self
    return unless sender_id == account_id
    errors.add :account, I18n.t('kudos.cant_kudo_self')
  end
end
