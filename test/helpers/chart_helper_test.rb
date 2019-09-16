# frozen_string_literal: true

require 'test_helper'

class ChartHelperTest < ActionView::TestCase
  include ChartHelper

  describe 'chart_default_time_span' do
    it 'should proper text' do
      chart_default_time_span.must_equal "#{7.years.ago.strftime('%b %Y')} - Present"
    end
  end

  describe 'chart_watermark' do
    it 'should return image options for chart' do
      watermark = chart_watermark['chart']
      watermark['backgroundColor'].must_equal 'transparent'
      watermark['style']['background-position'].must_equal '50% 50%'
      watermark['style']['background-repeat'].must_equal 'no-repeat'
    end
  end
end
