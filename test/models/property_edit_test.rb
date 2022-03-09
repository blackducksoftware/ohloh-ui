# frozen_string_literal: true

require 'test_helper'

class PropertyEditTest < ActiveSupport::TestCase
  before do
    project = create(:project, description: 'Linux')
    Edit.for_target(project).delete_all
    @undone_edit = create(:property_edit, value: 'Spammy!', created_at: Time.current + 5.days, target: project,
                                          undone: true, undone_at: Time.current + 5.days, undone_by: create(:admin).id)
    @edit = create(:property_edit, value: 'Linux', target: project)
    @previous_edit = create(:property_edit, value: '456', created_at: Time.current - 5.days, target: project)
  end

  it 'test_undo_fails_with_no_editor' do
    @edit.target.editor_account = nil
    _(proc { @edit.do_undo }).must_raise ActsAsEditable::UndoError
    @edit.target.reload
    _(@edit.target.description).must_equal 'Linux'
  end

  it 'test_undo_works_with_editor' do
    _(@edit.target.description).must_equal 'Linux'
    @edit.target.editor_account = create(:admin)
    @edit.do_undo
    @edit.target.reload
    _(@edit.target.description).must_equal '456'
  end

  it 'test_undo_respects_targets_edit_authorized' do
    @edit.target.editor_account = create(:admin)
    @edit.target.define_singleton_method(:edit_authorized?) { false }
    _(proc { @edit.do_undo }).must_raise ActsAsEditable::UndoError
    @edit.target.reload
    _(@edit.target.description).must_equal 'Linux'
  end

  it 'test_undo_respects_targets_allow_undo' do
    @edit.target.editor_account = create(:admin)
    @edit.target.define_singleton_method(:allow_undo?) { |_| false }
    @edit.key = :name
    _(proc { @edit.do_undo }).must_raise ActsAsEditable::UndoError
    @edit.target.reload
    _(@edit.target.description).must_equal 'Linux'
  end

  it 'test_undo_raises_if_update_fails' do
    @edit.target.editor_account = create(:admin)
    @edit.target.name = ''
    _(@edit.target).wont_be :valid?
    _(-> { @edit.do_undo }).must_raise ActsAsEditable::UndoError
  end

  it 'test_redo_fails_with_no_editor' do
    @undone_edit.target.editor_account = nil
    _(proc { @edit.do_redo }).must_raise ActsAsEditable::UndoError
    @undone_edit.target.reload
    _(@undone_edit.target.description).must_equal 'Linux'
  end

  it 'test_redo_works_with_editor' do
    _(@undone_edit.target.description).must_equal 'Linux'
    @undone_edit.target.editor_account = create(:admin)
    @undone_edit.do_redo
    @undone_edit.target.reload
    _(@undone_edit.target.description).must_equal 'Spammy!'
  end

  it 'test_redo_respects_targets_edit_authorized' do
    @undone_edit.target.editor_account = create(:admin)
    @undone_edit.target.define_singleton_method(:edit_authorized?) { false }
    _(proc { @edit.do_redo }).must_raise ActsAsEditable::UndoError
    @undone_edit.target.reload
    _(@undone_edit.target.description).must_equal 'Linux'
  end

  it 'test_redo_respects_targets_allow_redo' do
    @undone_edit.target.editor_account = create(:admin)
    @undone_edit.target.define_singleton_method(:allow_redo?) { |_| false }
    _(proc { @edit.do_redo }).must_raise ActsAsEditable::UndoError
    @undone_edit.target.reload
    _(@undone_edit.target.description).must_equal 'Linux'
  end

  it 'test_redo_raises_if_update_fails' do
    @undone_edit.target.editor_account = create(:admin)
    @undone_edit.target.name = ''
    _(@undone_edit.target).wont_be :valid?
    _(-> { @edit.do_redo }).must_raise ActsAsEditable::UndoError
  end

  it 'test_allow_undo_works' do
    [Project, Organization, Link, License, Alias].each do |klass|
      instance = klass.new
      _(instance.allow_undo_to_nil?(:not_disallowed)).must_equal true
    end
  end

  it 'test_allow_redo_works' do
    [Project].each do |klass|
      instance = klass.new
      _(instance.allow_redo?(:not_disallowed)).must_equal true
    end
  end

  it 'test_allow_redo_of_org_id_works_for_projects' do
    project1 = Project.new
    _(project1.allow_redo?(:organization_id)).must_equal true
    project2 = Project.new(organization_id: 1)
    _(project2.allow_redo?(:organization_id)).must_equal false
  end
end
