class Account < ActiveRecord::Base
  DEFAULT_LEVEL = 0
  ADMIN_LEVEL   = 10
  DISABLE_LEVEL = -10
  SPAMMER_LEVEL = -20

  oh_delegators :stack_extension, :organization_extension, :project_extension, :positions_core

  has_many :api_keys
  has_many :actions
  has_many :kudos
  has_many :sent_kudos, class_name: :Kudo, foreign_key: :sender_id
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
end
