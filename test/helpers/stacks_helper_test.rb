# frozen_string_literal: true

require 'test_helper'

class StacksHelperTest < ActionView::TestCase
  include StacksHelper

  describe 'stack_country_flag' do
    it 'must return an html with the flag image' do
      dummy_html = '<img/>'
      expects(:haml_tag).once.returns(dummy_html)

      _(stack_country_flag('Us')).must_equal dummy_html
    end

    it 'must handle invalid country codes' do
      _(stack_country_flag('invalid')).must_be :blank?
    end

    it 'must handle blank codes' do
      _(stack_country_flag(nil)).must_be :blank?
    end

    it 'must handle missing flag images' do
      _(stack_country_flag('uk')).must_be :blank?
    end

    it 'must use the assets_manifest when assets are not compiled' do
      Rails.configuration.assets.stubs(:compile).returns(false)
      Rails.application.assets_manifest.expects(:assets).once.returns({})

      _(stack_country_flag('')).must_be :blank?
    end
  end
end
