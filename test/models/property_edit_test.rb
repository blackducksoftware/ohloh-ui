require 'test_helper'

class PropertyEditTest < ActiveSupport::TestCase
  fixtures :accounts, :projects

  def setup
    project = create(:project, description: 'Linux')
    Edit.for_target(project).delete_all
    @undone_edit = create(:property_edit, value: 'Spammy!', created_at: Time.now + 5.days, target: project,
                                          undone: true, undone_at: Time.now + 5.days, undone_by: accounts(:admin).id)
    @edit = create(:property_edit, value: 'Linux', target: project)
    @previous_edit = create(:property_edit, value: '456', created_at: Time.now - 5.days, target: project)
  end

  def test_undo_fails_with_no_editor
    @edit.target.editor_account = nil
    assert_raises(ActsAsEditable::NoEditorAccountError) do
      @edit.do_undo
    end
    @edit.target.reload
    assert_equal 'Linux', @edit.target.description
  end

  def test_undo_works_with_editor
    assert_equal 'Linux', @edit.target.description
    @edit.target.editor_account = accounts(:admin)
    @edit.do_undo
    @edit.target.reload
    assert_equal '456', @edit.target.description
  end

  def test_undo_respects_targets_edit_authorized?
    @edit.target.editor_account = accounts(:admin)
    @edit.target.define_singleton_method(:edit_authorized?) { false }
    assert_raises(ActsAsEditable::UndoError) do
      @edit.do_undo
    end
    @edit.target.reload
    assert_equal 'Linux', @edit.target.description
  end

  def test_undo_respects_targets_allow_undo?
    @edit.target.editor_account = accounts(:admin)
    @edit.target.define_singleton_method(:allow_undo?) { |_| false }
    assert_raises(ActsAsEditable::UndoError) do
      @edit.do_undo
    end
    @edit.target.reload
    assert_equal 'Linux', @edit.target.description
  end

  def test_undo_raises_if_update_fails
    @edit.target.editor_account = accounts(:admin)
    @edit.target.define_singleton_method(:errors) { { errors: 'Yep!' } }
    assert_raises(ActsAsEditable::UndoError) do
      @edit.do_undo
    end
  end

  def test_redo_fails_with_no_editor
    @undone_edit.target.editor_account = nil
    assert_raises(ActsAsEditable::NoEditorAccountError) do
      @undone_edit.do_redo
    end
    @undone_edit.target.reload
    assert_equal 'Linux', @undone_edit.target.description
  end

  def test_redo_works_with_editor
    assert_equal 'Linux', @undone_edit.target.description
    @undone_edit.target.editor_account = accounts(:admin)
    @undone_edit.do_redo
    @undone_edit.target.reload
    assert_equal 'Spammy!', @undone_edit.target.description
  end

  def test_redo_respects_targets_edit_authorized?
    @undone_edit.target.editor_account = accounts(:admin)
    @undone_edit.target.define_singleton_method(:edit_authorized?) { false }
    assert_raises(ActsAsEditable::UndoError) do
      @undone_edit.do_redo
    end
    @undone_edit.target.reload
    assert_equal 'Linux', @undone_edit.target.description
  end

  def test_redo_respects_targets_allow_redo?
    @undone_edit.target.editor_account = accounts(:admin)
    @undone_edit.target.define_singleton_method(:allow_redo?) { |_| false }
    assert_raises(ActsAsEditable::UndoError) do
      @undone_edit.do_redo
    end
    @undone_edit.target.reload
    assert_equal 'Linux', @undone_edit.target.description
  end

  def test_redo_raises_if_update_fails
    @undone_edit.target.editor_account = accounts(:admin)
    @undone_edit.target.define_singleton_method(:errors) { { errors: 'Yep!' } }
    assert_raises(ActsAsEditable::UndoError) do
      @undone_edit.do_redo
    end
  end
end
