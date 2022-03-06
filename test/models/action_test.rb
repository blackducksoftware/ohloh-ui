# frozen_string_literal: true

require 'test_helper'

class ActionTest < ActiveSupport::TestCase
  let(:admin_account) { create(:admin) }
  let(:linux_project) { create(:project) }
  let(:person) { create(:person) }

  it 'test account required' do
    assert_no_difference 'Action.count' do
      action = Action.create
      _(action.errors).must_include(:account)
    end
  end

  it 'test action requires something to do' do
    assert_no_difference 'Action.count' do
      action = Action.create(account: admin_account)
      _(action.errors).must_include(:payload_required)
    end
  end

  it 'test create succeeds for claim' do
    assert_difference 'Action.count' do
      action = Action.create!(account: admin_account, claim: person)
      _(action.claim).must_equal person
      _(action.account).must_equal admin_account
    end
  end

  it 'test create succeeds for stacked project' do
    assert_difference 'Action.count' do
      action = Action.create(account: admin_account, stack_project: linux_project)
      _(action.stack_project).must_equal linux_project
    end
  end

  it 'test command for claim' do
    assert_difference 'Action.count' do
      action_param = "claim_#{person.id}"
      action = Action.create!(account: admin_account, _action: action_param)
      _(action.account).must_equal admin_account
      _(action.claim).must_equal person
    end
  end

  it 'test command for claim of person with no project' do
    assert_no_difference 'Action.count' do
      account = create(:account)
      action_param = "claim_#{account.person.id}"
      action = Action.create(account: admin_account, _action: action_param)
      _(action.errors.include?(:claim)).must_equal true
      _(action.errors).must_include(:claim)
    end
  end

  it 'test command for claim of person with no name' do
    assert_no_difference 'Action.count' do
      account = create(:account)
      action_param = "claim_#{account.person.id}"
      action = Action.create(account: admin_account, _action: action_param)
      _(action.errors).must_include(:claim)
    end
  end

  it 'test command for stacked project' do
    assert_difference 'Action.count' do
      action_param = "stack_#{linux_project.id}"
      action = Action.create!(account: admin_account, _action: action_param)
      _(action.account).must_equal admin_account
      _(action.stack_project).must_equal linux_project
    end
  end

  it 'test run with newly activated account' do
    action = Action.create!(account: admin_account, _action: "stack_#{linux_project.id}", status: 'after_activation')
    action.run
    _(admin_account.stack_core.default.projects).must_include(linux_project)
    _(action.status).must_equal Action::STATUSES[:remind]
  end
end
