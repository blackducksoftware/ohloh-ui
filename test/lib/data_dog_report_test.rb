# frozen_string_literal: true

require 'test_helper'

class DataDogReportTest < ActiveSupport::TestCase
  it 'must forward the message to rails logger' do
    Rails.logger.expects(:error).once
    DataDogReport.error('This is a custom event')
  end
end
