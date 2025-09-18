# frozen_string_literal: true

require 'test_helper'

class EditTest < ActiveSupport::TestCase
  before do
    @user = create(:account)
    @admin = create(:admin)
    project = create(:project, description: 'Linux')
    Edit.for_target(project).delete_all
    @edit = create(:create_edit, target: project)
    @previous_edit = create(:create_edit, value: '456', created_at: 5.days.ago, target: project)
  end

  it 'test_that_we_can_get_the_previous_value_of_an_edit' do
    _(@edit.previous_value).must_equal '456'
  end

  it 'test_that_previous_value_returns_nil_on_initial_edit' do
    _(@previous_edit.previous_value).must_be_nil
  end

  it 'test_that_undo_and_redo_work' do
    @edit.undo!(@admin)
    _(@edit.undone).must_equal true
    _(@edit.undoer).must_equal @admin
    @edit.redo!(@user)
    _(@edit.undone).must_equal false
    _(@edit.undoer).must_equal @user
  end

  it 'test_that_undo_requires_an_editor' do
    _(proc { @edit.undo!(nil) }).must_raise RuntimeError
  end

  it 'test_that_redo_requires_an_editor' do
    @edit.undo!(@admin)
    _(proc { @edit.undo!(nil) }).must_raise RuntimeError
  end

  it 'test_that_undo_can_only_be_called_once' do
    @edit.undo!(@admin)
    _(proc { @edit.undo!(@admin) }).must_raise ActsAsEditable::UndoError
  end

  it 'test_that_redo_can_only_be_called_after_an_undo' do
    _(proc { @edit.redo!(@admin) }).must_raise ActsAsEditable::UndoError
  end

  it 'test_that_project_gets_filled_in_automatically_for_project_edits' do
    p = create(:project)
    edit = CreateEdit.where(target: p).first
    _(edit.project_id).must_equal edit.target.id
    _(edit.organization_id).must_be_nil
  end

  it 'test_that_project_gets_filled_in_automatically_for_project_license_edits' do
    pl = create(:project_license, project: create(:project), license: create(:license))
    edit = CreateEdit.where(target: pl).first
    _(edit.project_id).must_equal edit.target.project.id
    _(edit.organization_id).must_be_nil
  end

  it 'test_that_organization_gets_filled_in_automatically_for_organization_edits' do
    org = create(:organization)
    edit = CreateEdit.where(target: org).first
    _(edit.organization_id).must_equal edit.target.id
    _(edit.project_id).must_be_nil
  end

  it 'test_that_project_and_organization_get_filled_in_automatically_when_associating_project_to_an_org' do
    p = create(:project, organization: nil)
    org = create(:organization)
    p.update(organization_id: org.id)
    edit = PropertyEdit.where(target: p, key: 'organization_id').first
    _(edit.project_id).must_equal p.id
    _(edit.value).must_equal org.id.to_s
  end

  it 'test_that_nothing_gets_filled_in_automatically_for_license_edits' do
    l = create(:license)
    edit = CreateEdit.where(target: l).first
    _(edit.project_id).must_be_nil
    _(edit.organization_id).must_be_nil
  end
end
