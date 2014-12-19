require_relative '../../test_helper'

class ProjectCoreTest < ActiveSupport::TestCase
  fixtures :accounts, :projects

  test "used" do
    account = accounts(:admin)
    stack = Stack.new
    project = Project.where{id.eq(1)}.first

    stack.projects << project
    account.stacks << stack
    account.save!

    account_project_core = account.project_core
    assert_equal [project], account_project_core.used.first
    assert_equal [project.logo_id], account_project_core.used.last.keys
  end

  test "stacked_count" do
    account = accounts(:admin)

    stack = Stack.new
    stack.projects << projects(:linux)
    account.stacks << stack
    account.save!

    account_project_core = account.project_core
    assert_equal 1, account_project_core.stacked_count
  end

  test "stacked?" do
    account = accounts(:admin)

    Stack.any_instance.stubs(:stacked_project?).with(projects(:linux).id).returns(true)
    assert_equal false, account.project_core.stacked?(projects(:linux).id)

    stack = Stack.new
    stack.projects << projects(:linux)
    account.stacks << stack
    account.save!

    assert_equal true, account.project_core.stacked?(projects(:linux).id)
  end
end