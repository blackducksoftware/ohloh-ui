require 'test_helper'

class StackEntryTest < ActiveSupport::TestCase
  it '#destroy updates deleted_at and does not remove record from db' do
    stack_entry = create(:stack_entry)
    stack_entry.destroy
    StackEntry.where(id: stack_entry.id).count.must_equal 1
  end

  it '#update_counters updates project.user_count' do
    proj = create(:project)
    proj.reload.user_count.must_equal 1
    stack_entry1 = create(:stack_entry, project: proj)
    proj.reload.user_count.must_equal 2
    stack_entry2 = create(:stack_entry, project: proj)
    proj.reload.user_count.must_equal 3
    stack_entry1.destroy
    proj.reload.user_count.must_equal 2
    stack_entry2.destroy
    proj.reload.user_count.must_equal 1
  end

  it '#update_counters updates stack.project_count' do
    stack = create(:stack)
    stack.reload.project_count.must_equal 0
    stack_entry1 = create(:stack_entry, stack: stack)
    stack.reload.project_count.must_equal 1
    stack_entry2 = create(:stack_entry, stack: stack)
    stack.reload.project_count.must_equal 2
    stack_entry1.destroy
    stack.reload.project_count.must_equal 1
    stack_entry2.destroy
    stack.reload.project_count.must_equal 0
  end
end
