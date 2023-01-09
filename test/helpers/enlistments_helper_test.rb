# frozen_string_literal: true

require 'test_helper'

class EnlistmentsHelperTest < ActionView::TestCase
  include EnlistmentsHelper

  describe 'must return endpoint of fisbot admin code locations' do
    it 'must return endpoint of fisbot admin code locations' do
      ids = [123, 2345]
      link = "#{ApiAccess.fis_public_url}/admin/code_locations?ids=#{ids.join(',')}"
      assert_equal link, code_location_ids_admin_url(ids)
    end
  end
end
