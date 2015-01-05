require_relative '../../test_helper'

class StackCoreTest < ActiveSupport::TestCase
  test 'default' do
    account = accounts(:admin)

    default_stack = account.stack_core.default
    assert_equal 1, account.stacks.size

    stack = Stack.new
    stack.projects << projects(:linux)
    account.stacks << stack
    account.save!

    account_stack_core = account.stack_core
    assert_equal 2, account.stacks.size
    assert_equal default_stack, account_stack_core.default
  end
end
