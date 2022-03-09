# frozen_string_literal: true

require_relative '../../test_helper'

class ProjectCoreTest < ActiveSupport::TestCase
  it 'used' do
    account = create(:admin)
    stack = create(:stack, account: account)
    project = create(:project)

    stack.projects << project
    stack.save!
    account.reload

    account_project_core = account.project_core
    _(account_project_core.used.first).must_equal [project]
    _(account_project_core.used.last.keys).must_equal [project.logo_id]
  end

  it 'stacked_count' do
    account = create(:admin)

    stack = create(:stack, account: account)
    stack.projects << create(:project)
    stack.save!
    account.reload

    account_project_core = account.project_core
    _(account_project_core.stacked_count).must_equal 1
  end

  it 'stacked?' do
    account = create(:admin)
    project = create(:project)

    Stack.any_instance.stubs(:stacked_project?).with(project.id).returns(true)
    _(account.project_core.stacked?(project.id)).must_equal false

    stack = create(:stack, account: account)
    stack.projects << project
    stack.save!
    account.reload

    _(account.project_core.stacked?(project.id)).must_equal true
  end
end
