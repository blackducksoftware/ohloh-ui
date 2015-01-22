require 'test_helper'

class StackTest < ActiveSupport::TestCase
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
end
