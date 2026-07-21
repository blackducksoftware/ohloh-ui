# frozen_string_literal: true

require 'test_helper'

class ClumpTest < ActiveSupport::TestCase
  describe 'path' do
    it 'should return nil when slave is nil' do
      clump = create(:clump)
      _(clump.path).must_be_nil
    end

    it 'should return path from slave when slave is present' do
      clump = create(:clump)
      slave = stub(path_from_code_set_id: '/var/local/clumps/000/000/000/001')
      clump.stubs(:slave).returns(slave)
      clump.stubs(:code_set_id).returns(1)
      _(clump.path).must_equal '/var/local/clumps/000/000/000/001'
    end
  end
end
