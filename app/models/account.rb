class Account < ActiveRecord::Base
  DEFAULT_LEVEL = 0
  ADMIN_LEVEL   = 10
  DISABLE_LEVEL = -10
  SPAMMER_LEVEL = -20

  has_many :api_keys
  has_many :stacks, -> { order 'stacks.title' }

  def admin?
    level == ADMIN_LEVEL
  end

  def default_stack
    stacks << Stack.new unless @cached_default_stack || stacks.count > 0
    @cached_default_stack ||= stacks[0]
  end
end
