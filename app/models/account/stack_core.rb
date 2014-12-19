class Account::StackCore < OhDelegator::Base
  parent_scope do
    has_many :stacks, -> { order { title } }
  end

  # TODO Replaces default_stack with this
  def default
    stacks << Stack.new unless @cached_default_stack || stacks.present?
    @cached_default_stack ||= stacks[0]
  end
end
