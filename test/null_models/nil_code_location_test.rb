# frozen_string_literal: true

require 'test_helper'

class NilCodeLocationTest < ActiveSupport::TestCase
  let(:nil_code_location) { NilCodeLocation.new }

  describe 'scm_type' do
    it 'should return git' do
      _(nil_code_location.scm_type).must_equal :git
    end
  end
end
