# frozen_string_literal: true

require_relative '../../test_helper'

class StackCoreTest < ActiveSupport::TestCase
  describe 'parent_scope' do
    let(:account) { create(:account, :with_stacks, number_of_stacks: 10) }

    before do
      @older_stack = create(:stack, account: account, updated_at: 1.hour.ago)
      @newer_stack = create(:stack, account: account, updated_at: 1.hour.from_now)
    end

    it 'should be reverse chronological ordered' do
      account.stacks.first.must_equal @newer_stack
      account.stacks.last.must_equal @older_stack
    end
  end

  it 'default' do
    account = create(:admin)

    default_stack = account.stack_core.default
    account.stacks.size.must_equal 1

    stack = create(:stack, account: account)
    stack.projects << create(:project)
    stack.save!
    account.reload

    account_stack_core = account.stack_core
    account.stacks.size.must_equal 2
    account_stack_core.default.must_equal default_stack
  end
end
