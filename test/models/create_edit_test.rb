# frozen_string_literal: true

require 'test_helper'

class CreateEditTest < ActiveSupport::TestCase
  before do
    @edit = create(:create_edit)
  end

  it 'test_undo_fails_with_no_editor' do
    @edit.target.editor_account = nil
    _(proc { @edit.do_undo }).must_raise ActiveRecord::RecordInvalid
    @edit.target.reload
    _(@edit.target.deleted).must_equal false
  end

  it 'test_undo_works_with_editor' do
    _(@edit.target.deleted).must_equal false
    @edit.target.editor_account = create(:admin)
    @edit.do_undo
    @edit.target.reload
    _(@edit.target.deleted).must_equal true
  end

  it 'test_redo_fails_with_no_editor' do
    @edit.target.editor_account = create(:admin)
    @edit.do_undo
    @edit.target.editor_account = nil
    _(@edit.target.deleted).must_equal true
    _(proc { @edit.do_redo }).must_raise ActiveRecord::RecordInvalid
    @edit.target.reload
    _(@edit.target.deleted).must_equal true
  end

  it 'test_redo_works_with_editor' do
    @edit.target.editor_account = create(:admin)
    @edit.do_undo
    _(@edit.target.deleted).must_equal true
    @edit.do_redo
    @edit.target.reload
    _(@edit.target.deleted).must_equal false
  end

  it 'shoud not allow undo for organization create_edit' do
    @edit.target = Organization.last
    @edit.target.editor_account = create(:admin)
    _(@edit.allow_undo?).must_equal false
  end
end
