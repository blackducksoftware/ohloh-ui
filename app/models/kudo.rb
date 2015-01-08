class Kudo < ActiveRecord::Base
  belongs_to :sender, foreign_key: :sender_id, class_name: :Account
  belongs_to :account

  # TODO: Replace recent_kudos.
  scope :recent, -> limit = 3 { limit(limit) }

  class << self
    # TODO: Replace display_sorted with sort_by_created_at
    def sort_by_created_at
      select(attribute_names)
        .select("#{ max_created_at_per_account } AS sort_time")
        .order('sort_time DESC, project_id DESC')
        .readonly
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
end
