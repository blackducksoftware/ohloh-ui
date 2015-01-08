require 'test_helper'

class EditTest < ActiveSupport::TestCase
  fixtures :accounts

  def setup
    project = create(:project, description: 'Linux')
    Edit.for_target(project).delete_all
    @edit = create(:create_edit, target: project)
    @previous_edit = create(:create_edit, value: '456', created_at: Time.now - 5.days, target: project)
  end

  def test_that_we_can_get_the_previous_value_of_an_edit
    assert_equal '456', @edit.previous_value
  end

  def test_that_previous_value_returns_nil_on_initial_edit
    assert_equal nil, @previous_edit.previous_value
  end

  def test_that_undo_and_redo_work
    @edit.undo!(accounts(:admin))
    assert_equal true, @edit.undone
    assert_equal accounts(:admin), @edit.undoer
    @edit.redo!(accounts(:user))
    assert_equal false, @edit.undone
    assert_equal accounts(:user), @edit.undoer
  end

  def test_that_undo_requires_an_editor
    assert_raises(RuntimeError) do
      @edit.undo!(nil)
    end
  end

  def test_that_redo_requires_an_editor
    @edit.undo!(accounts(:admin))
    assert_raises(RuntimeError) do
      @edit.undo!(nil)
    end
  end

  def test_that_undo_can_only_be_called_once
    @edit.undo!(accounts(:admin))
    assert_raises(ActsAsEditable::UndoError) do
      @edit.undo!(accounts(:admin))
    end
  end

  def test_that_redo_can_only_be_called_after_an_undo
    assert_raises(ActsAsEditable::UndoError) do
      @edit.redo!(accounts(:admin))
    end
  end

  def test_that_project_gets_filled_in_automatically_for_project_edits
    p = create(:project)
    edit = CreateEdit.where(target: p).first
    assert_equal edit.target.id, edit.project_id
    assert_equal nil, edit.organization_id
  end

  def test_that_project_gets_filled_in_automatically_for_project_license_edits
    pl = create(:project_license, project: create(:project), license: create(:license))
    edit = CreateEdit.where(target: pl).first
    assert_equal edit.target.project.id, edit.project_id
    assert_equal nil, edit.organization_id
  end

  def test_that_organization_gets_filled_in_automatically_for_organization_edits
    org = create(:organization)
    edit = CreateEdit.where(target: org).first
    assert_equal edit.target.id, edit.organization_id
    assert_equal nil, edit.project_id
  end

  def test_that_project_and_organization_get_filled_in_automatically_when_associating_project_to_an_org
    p = create(:project)
    org = create(:organization)
    p.update_attributes(organization_id: org.id)
    edit = PropertyEdit.where(target: p, key: 'organization_id').first
    assert_equal p.id, edit.project_id
    assert_equal org.id, edit.organization_id
  end

  def test_that_nothing_gets_filled_in_automatically_for_license_edits
    l = create(:license)
    edit = CreateEdit.where(target: l).first
    assert_equal nil, edit.project_id
    assert_equal nil, edit.organization_id
  end
end
