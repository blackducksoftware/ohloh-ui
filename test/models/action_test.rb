require 'test_helper'

class ActionTest < ActiveSupport::TestCase
  fixtures :accounts, :projects, :people, :names

  def test_account_required
    assert_no_difference 'Action.count' do
      action = Action.create
      assert action.errors.include?(:account)
    end
  end

  def test_action_requires_something_to_do
    assert_no_difference 'Action.count' do
      action = Action.create(account: admin_account)
      assert action.errors.include?(:payload_required)
    end
  end

  def test_create_succeeds_for_claim
    assert_difference 'Action.count' do
      person = people(:joe)
      action = Action.create!(account: admin_account, claim: person)
      assert_equal person, action.claim
      assert_equal admin_account, action.account
    end
  end

  def test_create_succeeds_for_stacked_project
    assert_difference 'Action.count' do
      action = Action.create(account: admin_account, stack_project: linux_project)
      assert_equal linux_project, action.stack_project
    end
  end

  def test_command_for_claim
    assert_difference 'Action.count' do
      action_param = "claim_#{people(:joe).id}"
      action = Action.create!(account: admin_account, _action: action_param)
      assert_equal admin_account, action.account
      assert_equal people(:joe), action.claim
    end
  end

  def test_command_for_claim_of_person_with_no_project
    assert_no_difference 'Action.count' do
      action_param = "claim_#{people(:kyle).id}"
      action = Action.create(account: admin_account, _action: action_param)
      assert action.errors.include?(:claim)
    end
  end

  def test_command_for_claim_of_person_with_no_name
    assert_no_difference 'Action.count' do
      action_param = "claim_#{people(:robin).id}"
      action = Action.create(account: admin_account, _action: action_param)
      assert action.errors.include?(:claim)
    end
  end

  def test_command_for_stacked_project
    assert_difference 'Action.count' do
      action_param = "stack_#{linux_project.id}"
      action = Action.create!(account: admin_account, _action: action_param)
      assert_equal admin_account, action.account
      assert_equal linux_project, action.stack_project
    end
  end

  def test_run_with_newly_activated_account
    action = Action.create!(account: admin_account, _action: "stack_#{linux_project.id}", status: 'after_activation')
    action.run
    assert admin_account.stack_extension.default.projects.include?(linux_project)
    assert_equal Action::STATUSES[:remind], action.status
  end

  def admin_account
    accounts(:admin)
  end

  def linux_project
    projects(:linux)
  end
end
