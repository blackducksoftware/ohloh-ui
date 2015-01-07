require 'test_helper'

class CreateEditTest < ActiveSupport::TestCase
  fixtures :accounts, :projects

  def setup
    @edit = create(:create_edit)
  end

  def test_undo_fails_with_no_editor
    assert_raises(ActsAsEditable::NoEditorAccountError) do
      @edit.do_undo
    end
    @edit.target.reload
    assert_equal false, @edit.target.deleted
  end

  def test_undo_works_with_editor
    assert_equal false, @edit.target.deleted
    @edit.target.editor_account = accounts(:admin)
    @edit.do_undo
    @edit.target.reload
    assert_equal true, @edit.target.deleted
  end

  def test_redo_fails_with_no_editor
    @edit.target.editor_account = accounts(:admin)
    @edit.do_undo
    @edit.target.editor_account = nil
    assert_equal true, @edit.target.deleted
    assert_raises(ActsAsEditable::NoEditorAccountError) do
      @edit.do_redo
    end
    @edit.target.reload
    assert_equal true, @edit.target.deleted
  end

  def test_redo_works_with_editor
    @edit.target.editor_account = accounts(:admin)
    @edit.do_undo
    assert_equal true, @edit.target.deleted
    @edit.do_redo
    @edit.target.reload
    assert_equal false, @edit.target.deleted
  end
end
