require 'test_helper'

class ChartHelperTest < ActionView::TestCase
  include ChartHelper

  describe 'chart_default_time_span' do
    it 'should proper text' do
      chart_default_time_span.must_equal "#{7.years.ago.strftime('%b %Y')} - Present"
    end
  end
end
