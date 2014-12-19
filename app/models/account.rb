class Account < ActiveRecord::Base
  DEFAULT_LEVEL = 0
  ADMIN_LEVEL   = 10
  DISABLE_LEVEL = -10
  SPAMMER_LEVEL = -20

  has_many :api_keys
  has_many :manages, -> { where.not(approved_by: nil).where(deleted_by: nil, deleted_at: nil) }
  has_many :projects, -> { where(deleted: false) }, through: :manages, source: :target, source_type: 'Project'
  has_many :stacks, -> { order 'stacks.title' }
  has_many :actions

  def admin?
    level == ADMIN_LEVEL
  end

  def disabled?
    level < DEFAULT_LEVEL
  end

  def activated?
    activated_at != nil
  end

  def default_stack
    stacks << Stack.new unless @cached_default_stack || stacks.count > 0
    @cached_default_stack ||= stacks[0]
  end

  class << self
    def hamster
      find_by_login('ohloh_slave')
    end
  end
end
