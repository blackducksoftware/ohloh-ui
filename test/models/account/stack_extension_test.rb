require_relative '../../test_helper'

class StackExtensionTest < ActiveSupport::TestCase
  fixtures :accounts, :projects

  test "default" do
    account = accounts(:admin)

    default_stack = account.stack_extension.default
    assert_equal 1, account.stacks.size

    stack = Stack.new
    stack.projects << projects(:linux)
    account.stacks << stack
    account.save!

    account_stack_extension = account.stack_extension
    assert_equal 2, account.stacks.size
    assert_equal default_stack, account_stack_extension.default
  end
end