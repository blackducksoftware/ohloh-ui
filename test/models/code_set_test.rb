require 'test_helper'

describe CodeSet do
  let(:clump) { create(:clump) }
  let(:code_set) { clump.code_set }

  describe 'reimport' do
    it 'should create a new code set, clump and import job' do
      Slave.any_instance.stubs(:run_local_or_remote).returns(true)
      repository = code_set.repository

      job = code_set.reimport

      Clump.find_by_id(clump.id).must_equal nil
      repository.code_sets.last.wont_equal code_set
      repository.code_sets.last.must_equal job.code_set
    end
  end

  describe 'ignore_prefixes' do
    it 'should ignore file names' do
      enlistment = create(:enlistment)
      code_set = create(:code_set, repository_id: enlistment.repository_id)
      code_set.ignore_prefixes(enlistment.project).must_be_empty
    end
  end
end
