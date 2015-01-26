require 'test_helper'

class NameFactTest < ActiveSupport::TestCase
  it '#for_project' do
    proj = create(:project)
    best = create(:analysis, project: proj)
    proj.update_columns(best_analysis_id: best.id)
    nf = create(:name_fact, analysis: best)

    NameFact.for_project(proj).first.id.must_equal nf.id
  end

  it '#<=> operator' do
    nf2 = create(:name_fact, last_checkin: Time.now - 2.days)
    nf3 = create(:name_fact, last_checkin: Time.now - 3.days)
    nf1 = create(:name_fact, last_checkin: Time.now - 1.days)
    nf4 = create(:name_fact, last_checkin: nil)

    [nf4, nf2, nf1, nf3].sort.map(&:id).must_equal [nf1.id, nf2.id, nf3.id, nf4.id]
  end
end
