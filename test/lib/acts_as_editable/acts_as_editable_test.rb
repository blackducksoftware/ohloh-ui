# frozen_string_literal: true

require 'test_helper'

class ActsAsEditable::ActsAsEditableTest < ActiveSupport::TestCase
  it 'edits get created on new project' do
    project = create(:project, name: 'Foo', description: 'Best of projects!', created_at: Time.current)
    _(CreateEdit.where(target: project).count).must_equal 1
    _(PropertyEdit.where(target: project, key: 'name', value: 'Foo').count).must_equal 1
    _(PropertyEdit.where(target: project, key: 'description', value: 'Best of projects!').count).must_equal 1
    _(PropertyEdit.where(target: project, key: 'updated_at').count).must_equal 0
  end

  it 'edits get their property edits merged if they are recent to one another' do
    project = create(:project, name: 'Foobar')
    project.update(name: 'Goobaz')
    _(PropertyEdit.where(target: project, key: 'name', value: 'Foobar').count).must_equal 0
    _(PropertyEdit.where(target: project, key: 'name', value: 'Goobaz').count).must_equal 1
  end

  it 'edits do not get their property edits merged if they are not recent to one another' do
    long_ago = Time.current - 5.days
    Time.stubs(:now).returns long_ago
    project = create(:project, name: 'Foobar')
    Time.unstub(:now)
    project.update(name: 'Goobaz')
    _(PropertyEdit.where(target: project, key: 'name', value: 'Foobar').count).must_equal 1
    _(PropertyEdit.where(target: project, key: 'name', value: 'Goobaz').count).must_equal 1
  end

  it 'edits do not get their property edits merged if they are not by the same editor' do
    project = create(:project, name: 'Foobar')
    project.editor_account = create(:account)
    project.update(name: 'Goobaz')
    _(PropertyEdit.where(target: project, key: 'name', value: 'Foobar').count).must_equal 1
    _(PropertyEdit.where(target: project, key: 'name', value: 'Goobaz').count).must_equal 1
  end

  it 'destroy does not delete from db and undoes the CreateEdit' do
    project = create(:project, name: 'Foobar')
    project.destroy
    project = Project.where(id: project.id).first
    _(project.deleted).must_equal true
    _(CreateEdit.where(target: project).first.undone).must_equal true
  end

  it 'destroy errors with no editor' do
    project = create(:project, name: 'Foobar')
    project = Project.where(id: project.id).first
    _(proc { project.destroy }).must_raise ActsAsEditable::NoEditorAccountError
    _(project.deleted).must_equal false
    _(CreateEdit.where(target: project).first.undone).must_equal false
  end

  it 'must record edits for custom attributes' do
    project = create(:project, organization: nil)
    _(PropertyEdit.where(key: %w[tag_list url], target: project).count).must_equal 0
    edits_count = PropertyEdit.where(target: project).count

    project.update(tag_list: Faker::Lorem.words.join(' '), url: Faker::Internet.url)

    _(PropertyEdit.where(target: project).count).must_equal edits_count + 2
    _(PropertyEdit.where(key: 'tag_list', target: project).count).must_equal 1
    _(PropertyEdit.where(key: 'url', target: project).count).must_equal 1
  end
end
