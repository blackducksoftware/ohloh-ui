require 'test_helper'

class NameFactTest < ActiveSupport::TestCase
  it '#for_project' do
    proj = create(:project)
    best = create(:analysis, project: proj)
    proj.update_columns(best_analysis_id: best.id)
    nf = create(:name_fact, analysis: best)

    NameFact.for_project(proj).first.id.must_equal nf.id
  end
end
