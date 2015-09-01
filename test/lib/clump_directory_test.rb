require 'test_helper'

class ClumpDirectoryTest < ActiveSupport::TestCase
  describe 'path' do
    it 'must return path created using the code_set_id' do
      ClumpDirectory.path(67).must_equal('/var/spool/clumps/000/000/000/067')
    end
  end

  describe 'code_set_ids' do
    it 'must return all code_set_ids using path to physical clumps on disk' do
      paths_on_disk = '/var/spool/clumps/000/000/000/158 /var/spool/clumps/000/000/000/162'
      Slave.any_instance.stubs(:run_on_clump_machine).returns(paths_on_disk)
      File.stubs(:exist?).returns(true)

      ClumpDirectory.code_set_ids.must_equal([158, 162])
    end
  end
end
