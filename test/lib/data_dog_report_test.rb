# frozen_string_literal: true

require 'test_helper'

class DataDogReportTest < ActiveSupport::TestCase
  it 'must send a create_event request to Datadog' do
    VCR.use_cassette('datadog_error_request') do
      assert_output(/This is error sample/) { DataDogReport.error('This is error sample') }
    end
  end
end
