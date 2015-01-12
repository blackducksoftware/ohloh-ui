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
end
