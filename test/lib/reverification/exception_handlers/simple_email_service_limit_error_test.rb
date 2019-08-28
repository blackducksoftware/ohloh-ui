# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/reverification'

class Reverification::ExceptionHandlers::SimpleEmailServiceLimitErrorTest < ActiveSupport::TestCase
  describe '#to_s' do
    it 'should start polling sqs queues' do
      Reverification::Process.expects(:start_polling_queues)
      Reverification::ExceptionHandlers::SimpleEmailServiceLimitError.new.to_s
    end
  end
end
