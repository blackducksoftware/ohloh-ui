require 'test_helper'

class Slave::SyncTest < ActiveSupport::TestCase
  let(:slave) { Slave.where(hostname: Socket.gethostname).first_or_create }
  let(:slave_sync) { Slave::Sync.new }

  describe 'execute' do
    it 'must create a slave log' do
      slave_sync.stubs(:destroy_clumps_lacking_code_set_directories)
      slave_sync.stubs(:delete_directories_for_clumps_without_code_set_in_db)
      slave_sync.stubs(:create_missing_clumps_for_code_sets_on_disk)

      assert_difference 'slave.logs.count' do
        slave_sync.execute
      end
    end

    it 'must destroy clump records in db missing physical directory on disk' do
      slave_sync.stubs(:delete_directories_for_clumps_without_code_set_in_db)
      slave_sync.stubs(:create_missing_clumps_for_code_sets_on_disk)

      clump = create(:git_clump)
      ClumpDirectory.stubs(:code_set_ids).returns([])

      slave_sync.execute

      Clump.find_by(id: clump.id).must_be_nil
    end

    it 'must delete directories for clumps missing code_set_id' do
      slave_sync.stubs(:destroy_clumps_lacking_code_set_directories)
      slave_sync.stubs(:create_missing_clumps_for_code_sets_on_disk)

      clump = create(:git_clump)
      clump.code_set.destroy

      ClumpDirectory.stubs(:code_set_ids).returns([clump.code_set_id])
      FileUtils.expects(:rm_rf).with(ClumpDirectory.path(clump.code_set_id))

      slave_sync.execute
    end

    it 'must create missing clump records for code_sets in db' do
      slave_sync.stubs(:destroy_clumps_lacking_code_set_directories)
      slave_sync.stubs(:delete_directories_for_clumps_without_code_set_in_db)

      code_set = create(:code_set)
      ClumpDirectory.stubs(:code_set_ids).returns([code_set.id])
      CodeSet.any_instance.expects(:find_or_create_clump)

      slave_sync.execute
    end
  end
end
