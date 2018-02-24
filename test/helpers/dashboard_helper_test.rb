require 'test_helper'

class DashboardHelperTest < ActionView::TestCase
  include DashboardHelper

  def last_deployment
    get_last_deployment
  end

  def get_revision_details
    ['abc123', Date.yesterday]
  end

  it 'should show the last deployment details' do
    get_last_deployment.match('https://github.com/blackducksoftware/ohloh-ui/commit/abc123')
  end
end
