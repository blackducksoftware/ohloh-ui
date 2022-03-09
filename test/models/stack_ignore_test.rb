# frozen_string_literal: true

require 'test_helper'

class StackIgnoreTest < ActiveSupport::TestCase
  it '#clean_up_entries will clear any previous entries on create' do
    stack_entry = create(:stack_entry)
    create(:stack_ignore, project: stack_entry.project, stack: stack_entry.stack)
    _(StackEntry.find(stack_entry.id).deleted_at).wont_equal nil
  end
end
