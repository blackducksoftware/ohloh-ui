require 'test_helper'

class AliasTest < ActiveSupport::TestCase
  it '#best_analysis_aliases' do
    proj = create(:project)
    best = create(:analysis, project: proj)
    create(:analysis, project: proj)
    proj.update_columns(best_analysis_id: best.id)
    name1 = create(:name)
    name2 = create(:name)
    create(:analysis_alias, analysis: best, commit_name: name1, preferred_name: name2)
    aka = create(:alias, project: proj, commit_name: name1, preferred_name: name2)

    Alias.best_analysis_aliases(proj).to_a.map(&:id).sort.must_equal [aka.id]
  end
end
