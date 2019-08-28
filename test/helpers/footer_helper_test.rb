# frozen_string_literal: true

require 'test_helper'

class FooterHelperTest < ActionView::TestCase
  include FooterHelper

  describe 'SettingsController' do
    it 'should be true for edit action' do
      selected?('edit', 'settings').must_equal true
    end

    it 'should be true for index action' do
      selected?('index', 'settings').must_equal true
    end

    it 'should be false for other restful actions' do
      selected?('show', 'settings').must_equal false
      selected?('update', 'settings').must_equal false
    end
  end
end
