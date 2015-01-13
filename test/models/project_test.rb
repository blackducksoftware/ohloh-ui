require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  it 'hot_projects should return hot projects' do
    proj = create(:project, deleted: false)
    analysis = create(:analysis, project_id: proj.id, hotness_score: 999_999)
    proj.update_attributes(best_analysis_id: analysis.id)
    Project.hot_projects.to_a.map(&:id).include?(proj.id).must_equal true
  end

  it 'hot_projects should return hot projects with matching languages' do
    proj = create(:project, deleted: false)
    analysis = create(:analysis, project_id: proj.id, hotness_score: 999_999, main_language_id: 1)
    proj.update_attributes(best_analysis_id: analysis.id)
    Project.hot_projects(1).to_a.map(&:id).include?(proj.id).must_equal true
  end

  it 'hot_projects should not return hot projects without matching languages' do
    proj = create(:project, deleted: false)
    analysis = create(:analysis, project_id: proj.id, hotness_score: 999_999, main_language_id: 1)
    proj.update_attributes(best_analysis_id: analysis.id)
    Project.hot_projects(2).to_a.map(&:id).include?(proj.id).must_equal false
  end

  it 'related_by_stacks should return related projects' do
    project1 = create(:project)
    project2 = create(:project)
    project3 = create(:project)
    stack1 = create(:stack)
    stack2 = create(:stack)
    stack3 = create(:stack)
    create(:stack_entry, stack: stack1, project: project1)
    create(:stack_entry, stack: stack1, project: project2)
    create(:stack_entry, stack: stack1, project: project3)
    create(:stack_entry, stack: stack2, project: project1)
    create(:stack_entry, stack: stack2, project: project2)
    create(:stack_entry, stack: stack2, project: project3)
    create(:stack_entry, stack: stack3, project: project1)
    create(:stack_entry, stack: stack3, project: project2)
    create(:stack_entry, stack: stack3, project: project3)
    project1.related_by_stacks.to_a.map(&:id).sort.must_equal [project2.id, project3.id]
    project2.related_by_stacks.to_a.map(&:id).sort.must_equal [project1.id, project3.id]
    project3.related_by_stacks.to_a.map(&:id).sort.must_equal [project1.id, project2.id]
  end

  it 'related_by_stacks should return related projects' do
    project1 = create(:project)
    project2 = create(:project)
    project3 = create(:project)
    tag = create(:tag)
    create(:tagging, tag: tag, taggable: project1)
    create(:tagging, tag: tag, taggable: project2)
    create(:tagging, tag: tag, taggable: project3)
    project1.related_by_tags.to_a.map(&:id).sort.must_equal [project2.id, project3.id]
    project2.related_by_tags.to_a.map(&:id).sort.must_equal [project1.id, project3.id]
    project3.related_by_tags.to_a.map(&:id).sort.must_equal [project1.id, project2.id]
  end
end
