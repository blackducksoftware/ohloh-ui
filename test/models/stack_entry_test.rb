# frozen_string_literal: true

require 'test_helper'

class StackEntryTest < ActiveSupport::TestCase
  it '#destroy updates deleted_at and does not remove record from db' do
    stack_entry = create(:stack_entry)
    stack_entry.destroy
    _(StackEntry.where(id: stack_entry.id).count).must_equal 1
  end

  it '#update_counters updates project.user_count' do
    proj = create(:project)
    _(proj.reload.user_count).must_equal 1
    stack_entry1 = create(:stack_entry, project: proj)
    _(proj.reload.user_count).must_equal 1
    stack_entry2 = create(:stack_entry, project: proj)
    _(proj.reload.user_count).must_equal 2
    stack_entry1.destroy
    _(proj.reload.user_count).must_equal 1
    stack_entry2.destroy
    _(proj.reload.user_count).must_equal 0
  end

  it '#update_counters updates stack.project_count' do
    stack = create(:stack)
    _(stack.reload.project_count).must_equal 0
    stack_entry1 = create(:stack_entry, stack: stack)
    _(stack.reload.project_count).must_equal 1
    stack_entry2 = create(:stack_entry, stack: stack)
    _(stack.reload.project_count).must_equal 2
    stack_entry1.destroy
    _(stack.reload.project_count).must_equal 1
    stack_entry2.destroy
    _(stack.reload.project_count).must_equal 0
  end

  it '#clean_up_ignores will clear any previous ignores on create' do
    stack_ignore = create(:stack_ignore)
    create(:stack_entry, project: stack_ignore.project, stack: stack_ignore.stack)
    _(-> { StackIgnore.find(stack_ignore.id) }).must_raise ActiveRecord::RecordNotFound
  end

  it '#project_name works' do
    stack_entry = create(:stack_entry)
    project = create(:project)
    stack_entry.project_name = project.name.upcase
    _(stack_entry.project_name).must_equal project.name
    _(stack_entry.project).must_equal project
  end
end
