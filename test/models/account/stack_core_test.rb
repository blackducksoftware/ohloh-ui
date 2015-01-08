require_relative '../../test_helper'

class StackCoreTest < ActiveSupport::TestCase
  it 'default' do
    account = accounts(:admin)

    default_stack = account.stack_core.default
    account.stacks.size.must_equal 1

    stack = Stack.new
    stack.projects << projects(:linux)
    account.stacks << stack
    account.save!

    account_stack_core = account.stack_core
    account.stacks.size.must_equal 2
    account_stack_core.default.must_equal default_stack
  end
end
