# frozen_string_literal: true

require 'test_helper'

class StackTest < ActiveSupport::TestCase
  let(:stack) { create(:stack) }

  it 'must allow creating nested stack_entry alongwith parent record' do
    account = create(:account)
    project = create(:project)

    stack = Stack.create!(account_id: account.id, stack_entries_attributes: { '0' => { project_id: project.id } })

    _(stack.stack_entries.first.project).must_equal project
  end

  it '#sanitize_description leaves nils alone' do
    _(create(:stack, description: nil).description).must_be_nil
  end

  it '#sanitize_description strips html tags' do
    _(create(:stack, description: '<script>alert("foo");</script>').description).must_equal 'alert("foo");'
  end

  it '#sandox? returns false for most stacks' do
    _(create(:stack).sandox?).must_equal false
  end

  it '#sandox? returns true for session stacks' do
    _(create(:stack, account: nil, project: nil, session_id: 'my_session_id').sandox?).must_equal true
  end

  it '#similar_stacks finds similar stacks' do
    stack1 = create(:stack)
    stack2 = create(:stack)
    stack3 = create(:stack)
    stack4 = create(:stack)

    proj1 = create(:project)
    proj2 = create(:project)
    proj3 = create(:project)
    proj4 = create(:project)
    proj5 = create(:project)

    stack1.projects = [proj1, proj2, proj3]
    stack2.projects = [proj2, proj3]
    stack3.projects = [proj1, proj3]
    stack4.projects = [proj4, proj5]

    _(stack3.similar_stacks.pluck(:stack).map(&:id)).must_equal [stack1.id, stack2.id]
    _(stack3.similar_stacks[0][:shared_projects].map(&:id).sort).must_equal [proj1.id, proj3.id].sort
    _(stack3.similar_stacks[1][:shared_projects].map(&:id)).must_equal [proj3.id]
    _(stack3.similar_stacks[0][:uniq_projects].map(&:id)).must_equal [proj2.id]
    _(stack3.similar_stacks[1][:uniq_projects].map(&:id)).must_equal [proj2.id]
  end

  it '#suggest_projects suggests related projects' do
    stack1 = create(:stack)
    stack2 = create(:stack)
    stack3 = create(:stack)
    stack4 = create(:stack)

    proj1 = create(:project)
    proj2 = create(:project)
    proj3 = create(:project)
    proj4 = create(:project)

    stack1.projects = [proj1, proj2, proj3]
    stack2.projects = [proj2, proj3]
    stack3.projects = [proj1, proj3]
    stack4.projects = [proj4]

    _(stack3.suggest_projects(2).map(&:id)).must_equal [proj2.id, proj4.id]
  end

  describe 'name' do
    it 'should return if title is present' do
      stack.stubs(:title).returns('test')

      _(stack.name).must_equal 'test'
    end

    it 'should return default' do
      stack.stubs(:title).returns(nil)

      _(stack.name).must_equal 'Default'
    end

    it 'should return with project name' do
      project = create(:project)
      stack.stubs(:title).returns(nil)
      stack.stubs(:account).returns(nil)
      stack.stubs(:project).returns(project)

      _(stack.name).must_equal "#{project.name}'s Stack"
    end

    it 'should return unnamed' do
      stack.stubs(:title).returns(nil)
      stack.stubs(:account).returns(nil)

      _(stack.name).must_equal 'Unnamed'
    end
  end

  describe 'friendly_name' do
    it 'should return name with stack appended' do
      stack.stubs(:name).returns('test')
      _(stack.friendly_name).must_equal 'test Stack'
    end

    it 'should return name without stack appended' do
      stack.stubs(:name).returns('TestStack')
      _(stack.friendly_name).must_equal 'TestStack'
    end
  end

  describe 'stacked_project?' do
    it 'should find stack entry for project' do
      stack = create(:stack)
      project1 = create(:project)
      project2 = create(:project)

      stack.projects = [project1, project2]

      _(stack.stacked_project?(project1.id).class).must_equal StackEntry
    end
  end
end
