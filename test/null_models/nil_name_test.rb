# frozen_string_literal: true

require 'test_helper'

class NilNameFactTest < ActiveSupport::TestCase
  let(:nil_name) { NilName.new }

  describe 'name' do
    it 'should return empty string' do
      nil_name.name.must_equal ''
    end
  end
end
