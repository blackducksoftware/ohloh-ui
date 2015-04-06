require 'test_helper'

class EnlistmentTest < ActiveSupport::TestCase
  let(:project) { create(:project) }
  let(:repository) { create(:repository) }
  let(:enlistment) { create(:enlistment) }
  let(:fyle) { create(:fyle) }

  it '#enlist_project_in_repository creates an enlistment' do
    r = Enlistment.enlist_project_in_repository(create(:account), project, repository, 'stop ignoring me!')
    r.project_id.must_equal project.id
    r.repository_id.must_equal repository.id
    r.ignore.must_equal 'stop ignoring me!'
  end

  it '#enlist_project_in_repository undeletes old enlistment' do
    r1 = Enlistment.enlist_project_in_repository(create(:account), project, repository)
    r1.destroy
    r1.reload
    r1.deleted.must_equal true
    r2 = Enlistment.enlist_project_in_repository(create(:account), project, repository)
    r2.deleted.must_equal false
    r1.id.must_equal r2.id
  end

  describe 'ignore_examples' do
    it 'should return empty array' do
      enlistment.ignore_examples.must_equal nil
    end

    it 'should return fyles' do
      enlistment.repository.best_code_set_id = fyle.code_set_id
      enlistment.ignore_examples.count.must_equal 1
      enlistment.ignore_examples.first.must_equal fyle.name
    end
  end

  describe 'analysis_sloc_set' do
    it 'should return nil if best_analysis is nil' do
      enlistment.analysis_sloc_set.must_equal nil
    end

    it 'should return analysis_sloc_set' do
      analysis_sloc_set = create(:analysis_sloc_set, analysis: enlistment.project.best_analysis)
      enlistment.repository.update(best_code_set_id: analysis_sloc_set.sloc_set.code_set_id)
      enlistment.analysis_sloc_set.must_equal analysis_sloc_set
    end
  end
end
