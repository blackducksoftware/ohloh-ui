# frozen_string_literal: true

require 'test_helper'

class AppLoggerTest < ActiveSupport::TestCase
  it 'must forward the error message to rails logger' do
    AppLogger.expects(:error).once
    AppLogger.error('This is a custom event')
  end

  it 'must forward the info message to logger' do
    AppLogger.expects(:info).once
    AppLogger.info('This is another custom event')
  end
end
