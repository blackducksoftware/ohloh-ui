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
    account_project_core.used.first.must_equal [project]
    account_project_core.used.last.keys.must_equal [project.logo_id]
  end

  it 'stacked_count' do
    account = create(:admin)

    stack = create(:stack, account: account)
    stack.projects << projects(:linux)
    stack.save!
    account.reload

    account_project_core = account.project_core
    account_project_core.stacked_count.must_equal 1
  end

  it 'stacked?' do
    account = create(:admin)

    Stack.any_instance.stubs(:stacked_project?).with(projects(:linux).id).returns(true)
    account.project_core.stacked?(projects(:linux).id).must_equal false

    stack = create(:stack, account: account)
    stack.projects << projects(:linux)
    stack.save!
    account.reload

    account.project_core.stacked?(projects(:linux).id).must_equal true
  end
end
