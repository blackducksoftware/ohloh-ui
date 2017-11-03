require 'test_helper'

describe CodeSet do
  let(:clump) { create(:clump) }
  let(:code_set) { clump.code_set }

  describe 'reimport' do
    it 'should create a new code set, clump and import job' do
      # Clone the most recently updated clump, which we want to be the factory created one.
      # So make one more older GitClump to test the sort.
      code_set.clumps << GitClump.create(slave: Slave.first)
      code_set.clumps.last.update_attribute(:updated_at, clump.updated_at - 2.days)
      Slave.any_instance.stubs(:run_local_or_remote).returns(true)
      code_location = code_set.code_location

      job = code_set.reimport

      assert_nil Clump.find_by_id(clump.id)
      code_location.code_sets.last.wont_equal code_set
      code_location.code_sets.last.must_equal job.code_set
    end
  end

  describe 'ignore_prefixes' do
    it 'should ignore file names' do
      enlistment = create(:enlistment)
      code_set = create(:code_set, code_location_id: enlistment.code_location_id)
      code_set.ignore_prefixes(enlistment.project).must_be_empty
    end
  end

  describe 'test oldest oldest_code_set' do
    it 'should return the oldest code set' do
      enlistment = create(:enlistment)

      analysis = create(:analysis, min_month: Date.current - 5.months, oldest_code_set_time: Time.zone.now)
      enlistment.project.update_column(:best_analysis_id, analysis.id)
      code_set = create(:code_set, code_location_id: enlistment.code_location_id)
      code_location = CodeLocation.find(enlistment.code_location_id)
      code_location.update_attribute('best_code_set_id', code_set.id)
      # to do - make this test return a non- zero count
      assert CodeSet.oldest_code_set.count == 0
    end
  end
end
