# frozen_string_literal: true

require 'test_helper'

class DataDogReportTest < ActiveSupport::TestCase
  it 'must send a create_event request to Datadog' do
    VCR.use_cassette('datadog_error_request') do
      response = DataDogReport.error('This is an error sample')
      _(response.to_hash[:status]).must_equal 'ok'
    end
  end
end
