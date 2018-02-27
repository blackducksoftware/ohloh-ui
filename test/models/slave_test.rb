require 'test_helper'

describe Slave do
  let(:slave) { create(:slave) }

  describe 'run_local_or_remote' do
    it 'should run command locally' do
      slave.stubs(:local?).returns(true)
      slave.run_local_or_remote('sleep 1').must_equal ''
    end

    it 'should run command via ssh' do
      slave.stubs(:local?).returns(false)
      slave.run_local_or_remote('cat test.rb').must_equal "ssh #{slave.hostname} 'cat test.rb'"
    end

    it 'should show error when running commandfor invalid command' do
      slave.stubs(:local?).returns(true)
      proc { slave.run_local_or_remote('cat invalid.rb') }.must_raise(RuntimeError)
    end
  end

  describe 'allow_deny' do
    it 'allow must be true when value is allow' do
      slave = Slave.new(allow_deny: 'allow')
      slave.must_be :allow?
    end

    it 'deny must be true when value is deny' do
      slave = Slave.new(allow_deny: 'deny')
      slave.must_be :deny?
    end

    it 'allow or deny must be false when value is invalid' do
      slave = Slave.new(allow_deny: 'junk')
      slave.wont_be :allow?
      slave.wont_be :deny?
    end
  end

  describe 'path_from_code_set_id' do
    it 'should return path based on the given code_set_id' do
      slave.path_from_code_set_id(300).must_equal '/var/local/clumps/000/000/000/300'
    end
  end
end
