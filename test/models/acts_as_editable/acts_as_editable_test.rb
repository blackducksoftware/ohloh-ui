require 'test_helper'
require "#{Rails.root}/test/mocks/mock_active_record_base"

class MockEditableRecord < MockActiveRecordBase
  include ActiveModel::Dirty
  acts_as_editable editable_attributes: [],
                   merge_within: 30.minutes,
                   edit_description: :edit_desc_callback

  def edit_desc_callback
  end

  def persisted?
    true
  end

  def id
    1
  end
end

class ActsAsEditable::ActsAsEditableTest < ActiveSupport::TestCase
  fixtures :accounts

  def setup
    @editor_instance = MockEditableRecord.new
  end

  test 'edit_description option should be invoked during save' do
    @editor_instance.editor_account = accounts(:admin)
    @editor_instance.expects(:edit_desc_callback)
    assert @editor_instance.save
  end

  test 'edits get created on new project' do
    project = create(:project, name: 'Foo', description: 'Best of projects!', created_at: Time.now)
    assert_equal 1, CreateEdit.where(target: project).count
    assert_equal 1, PropertyEdit.where(target: project, key: 'name', value: 'Foo').count
    assert_equal 1, PropertyEdit.where(target: project, key: 'description', value: 'Best of projects!').count
    assert_equal 0, PropertyEdit.where(target: project, key: 'updated_at').count
  end

  test 'edits get their property edits merged if they are recent to one another' do
    project = create(:project, name: 'Foobar')
    project.update_attributes(name: 'Goobaz')
    assert_equal 0, PropertyEdit.where(target: project, key: 'name', value: 'Foobar').count
    assert_equal 1, PropertyEdit.where(target: project, key: 'name', value: 'Goobaz').count
  end

  test 'edits do not get their property edits merged if they are not recent to one another' do
    long_ago = Time.now - 5.days
    Time.stubs(:now).returns long_ago
    project = create(:project, name: 'Foobar')
    Time.unstub(:now)
    project.update_attributes(name: 'Goobaz')
    assert_equal 1, PropertyEdit.where(target: project, key: 'name', value: 'Foobar').count
    assert_equal 1, PropertyEdit.where(target: project, key: 'name', value: 'Goobaz').count
  end

  test 'edits do not get their property edits merged if they are not by the same editor' do
    project = create(:project, name: 'Foobar')
    project.editor_account = accounts(:user)
    project.update_attributes(name: 'Goobaz')
    assert_equal 1, PropertyEdit.where(target: project, key: 'name', value: 'Foobar').count
    assert_equal 1, PropertyEdit.where(target: project, key: 'name', value: 'Goobaz').count
  end

  test 'destroy does not delete from db and undoes the CreateEdit' do
    project = create(:project, name: 'Foobar')
    project.destroy
    project = Project.where(id: project.id).first
    assert_equal true, project.deleted
    assert_equal true, CreateEdit.where(target: project).first.undone
  end

  test 'destroy errors with no editor' do
    project = create(:project, name: 'Foobar')
    project = Project.where(id: project.id).first
    assert_raises(ActsAsEditable::NoEditorAccountError) do
      project.destroy
    end
    assert_equal false, project.deleted
    assert_equal false, CreateEdit.where(target: project).first.undone
  end
end
