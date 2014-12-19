require_relative '../../test_helper'

class ProjectExtensionTest < ActiveSupport::TestCase
  fixtures :accounts, :projects

  test "used" do
    account = accounts(:admin)
    stack = Stack.new
    project = Project.where{id.eq(1)}.first
    
    stack.projects << project
    account.stacks << stack
    account.save!

    account_project_extension = account.project_extension
    assert_equal [project], account_project_extension.used.first
    assert_equal [project.logo_id], account_project_extension.used.last.keys
  end

  test "stacked_count" do
    account = accounts(:admin)

    stack = Stack.new
    stack.projects << projects(:linux)
    account.stacks << stack
    account.save!

    account_project_extension = account.project_extension
    assert_equal 1, account_project_extension.stacked_count
  end

  test "stacked?" do
    account = accounts(:admin)

    Stack.any_instance.stubs(:stacked_project?).with(projects(:linux).id).returns(true)
    assert_equal false, account.project_extension.stacked?(projects(:linux).id)

    stack = Stack.new
    stack.projects << projects(:linux)
    account.stacks << stack
    account.save!

    assert_equal true, account.project_extension.stacked?(projects(:linux).id)
  end
end