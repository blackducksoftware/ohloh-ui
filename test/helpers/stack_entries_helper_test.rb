# frozen_string_literal: true

require 'test_helper'

class StackEntriesHelperTest < ActionView::TestCase
  include StackEntriesHelper

  describe 'check_box_params' do
    it 'should include checked if requested to do so' do
      opts = check_box_params(true, create(:stack), create(:project))
      _(opts[:checked]).must_equal 'checked'
    end

    it 'should not include checked if requested to not do so' do
      opts = check_box_params(false, create(:stack), create(:project))
      _(opts[:checked]).must_be_nil
    end
  end
end
