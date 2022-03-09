# frozen_string_literal: true

require 'test_helper'

class WidgetsHelperTest < ActionView::TestCase
  include WidgetsHelper

  let(:factoid) { Factoid.new }
  let(:account) { create(:account) }
  let(:widget) { AccountWidget::Detailed.new(account_id: account.id, test: 'test') }

  describe 'factoid_image_path' do
    it 'should return good image path' do
      factoid.stubs(:severity).returns(50)
      _(factoid_image_path(factoid)).must_equal '/fact_good.png'
    end

    it 'should return info image path' do
      factoid.stubs(:severity).returns(0)
      _(factoid_image_path(factoid)).must_equal '/fact_info.png'
    end

    it 'should return warning image path' do
      factoid.stubs(:severity).returns(-1)
      _(factoid_image_path(factoid)).must_equal '/fact_warning.png'
    end

    it 'should return bad image path' do
      factoid.stubs(:severity).returns(-75)
      _(factoid_image_path(factoid)).must_equal '/fact_bad.png'
    end

    it 'should return info image path when rating is others' do
      factoid.stubs(:severity).returns(-9_000)
      _(factoid_image_path(factoid)).must_equal '/fact_info.png'
    end
  end

  describe 'widget_image_url' do
    it 'should return image path as it is' do
      img_path = '/fact_info.png'
      _(widget_image_url(img_path)).must_equal img_path
    end

    it 'should return image full path' do
      img_path = '/fact_info.png'
      _(widget_image_url('/fact_info.png')).must_equal img_path
    end
  end

  describe 'widget_ohloh_logo_url' do
    it 'should return logo url' do
      _(widget_ohloh_logo_url).must_equal '/widget_logos/openhublogo.png'
    end
  end

  describe 'widget_url' do
    it 'should return url based on type' do
      path = "http://test.host/accounts/#{account.login}/widgets/account_detailed?format=js&test=test"
      stubs(:controller_name).returns(:account_widgets)
      widget = AccountWidget::Detailed.new(account_id: account.id, test: 'test')
      _(widget_url(widget, 'account')).must_equal path
    end
  end

  describe 'widget_url_without_format' do
    it 'should return url based on type' do
      path = "http://test.host/accounts/#{account.login}/widgets/account_detailed?test=test"
      stubs(:controller_name).returns(:account_widgets)
      _(widget_url_without_format(widget, 'account')).must_equal path
    end
  end

  describe 'widget_iframe_style' do
    it 'should return css' do
      _(widget_iframe_style(widget)).must_equal 'height: 35px; width: 230px; border: none'
    end
  end

  describe 'widget_gif_url' do
    it 'should return url with gif format' do
      path = "http://test.host/accounts/#{account.login}/widgets/account_detailed?format=gif&ref=sample"
      url = widget_gif_url(detailed_account_widgets_url(account), 'sample')
      _(url).must_equal path
    end
  end
end
