require 'test_helper'

class ClumpTest < ActiveSupport::TestCase
  it 'scm_class: must return GitAdapter by default' do
    Clump.new.scm_class.must_equal(OhlohScm::Adapters::GitAdapter)
  end

  it 'branch_name: must get the value from code_set.repository' do
    clump = build(:clump)
    clump.branch_name.must_equal(clump.code_set.repository.branch_name)
  end

  it 'scm: must instantiate a new scm_class' do
    clump = build(:clump)
    clump.scm.must_be_instance_of(clump.scm_class)
  end

  describe 'open' do
    it 'must yield itself to the block' do
      clump = build(:clump)

      clump.open do |object|
        object.must_equal clump
      end
    end

    it 'must call clean_up_disk for cleaning git repositories' do
      clump = build(:clump)

      clump.scm.expects(:clean_up_disk)
      clump.open {}
    end
  end

  describe 'update_fetched_at' do
    it 'must update fetched_at when no fetched_at' do
      clump = create(:git_clump)
      clump.fetched_at.must_be_nil

      newtime = Time.current
      clump.update_fetched_at(newtime)
      clump.reload.fetched_at.to_i.must_equal newtime.to_i
    end
  end

  describe 'oldest_fetchable' do
    it 'must return the oldest clump' do
      clump = create(:git_clump)
      repository = create(:git_repository)
      repository.update! best_code_set_id: clump.code_set_id
      repository.jobs.destroy_all

      Clump.oldest_fetchable.first.must_equal clump
    end
  end
end
