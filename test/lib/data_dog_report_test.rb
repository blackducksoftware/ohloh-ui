# frozen_string_literal: true

require 'test_helper'

class DataDogReportTest < ActiveSupport::TestCase
  it 'must forward the error message to rails logger' do
    Rails.logger.expects(:error).once
    DataDogReport.error('This is a custom event')
  end

  it 'must forward the info message to logger' do
    Logger.any_instance.expects(:info).once
    DataDogReport.info('This is another custom event')
  end
end
