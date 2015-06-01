require 'test_helper'

class StackTest < ActiveSupport::TestCase
  let(:stack) { create(:stack) }

  it '#sanitize_description leaves nils alone' do
    create(:stack, description: nil).description.must_equal nil
  end

  it '#sanitize_description strips html tags' do
    create(:stack, description: '<script>alert("foo");</script>').description.must_equal 'alert("foo");'
  end

  it '#sandox? returns false for most stacks' do
    create(:stack).sandox?.must_equal false
  end

  it '#sandox? returns true for session stacks' do
    create(:stack, account: nil, project: nil, session_id: 'my_session_id').sandox?.must_equal true
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

    stack3.similar_stacks.map { |h| h[:stack] }.map(&:id).must_equal [stack1.id, stack2.id]
    stack3.similar_stacks[0][:shared_projects].map(&:id).must_equal [proj1.id, proj3.id]
    stack3.similar_stacks[1][:shared_projects].map(&:id).must_equal [proj3.id]
    stack3.similar_stacks[0][:uniq_projects].map(&:id).must_equal [proj2.id]
    stack3.similar_stacks[1][:uniq_projects].map(&:id).must_equal [proj2.id]
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

    stack3.suggest_projects(2).map(&:id).must_equal [proj2.id, proj4.id]
  end

  describe 'name' do
    it 'should return if title is present' do
      stack.stubs(:title).returns('test')

      stack.name.must_equal 'test'
    end

    it 'should return default' do
      stack.stubs(:title).returns(nil)

      stack.name.must_equal 'Default'
    end

    it 'should return with project name' do
      project = create(:project)
      stack.stubs(:title).returns(nil)
      stack.stubs(:account).returns(nil)
      stack.stubs(:project).returns(project)

      stack.name.must_equal "#{project.name}'s Stack"
    end

    it 'should return unnamed' do
      stack.stubs(:title).returns(nil)
      stack.stubs(:account).returns(nil)

      stack.name.must_equal 'Unnamed'
    end
  end

  describe 'friendly_name' do
    it 'should return name with stack appended' do
      stack.stubs(:name).returns('test')
      stack.friendly_name.must_equal 'test Stack'
    end

    it 'should return name without stack appended' do
      stack.stubs(:name).returns('TestStack')
      stack.friendly_name.must_equal 'TestStack'
    end
  end

  describe 'auto generate title and description' do
    it 'should autopopulate a blank title and description' do
      account = create(:account)
      stack = create(:stack, title: nil, description: nil)
      account.stacks << stack
      stack.auto_generate_title_and_description(account.stacks.count)
      stack.title.must_equal "New Stack 1"
      stack.description.must_equal "The Projects used for New Stack 1"
    end
  end
end
