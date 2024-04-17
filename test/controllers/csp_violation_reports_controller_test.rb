# frozen_string_literal: true

require 'test_helper'

class CspViolationReportsControllerTest < ActionController::TestCase
  it 'must notify errbit' do
    @controller.expects(:notify_airbrake).once
    post :report
  end
end
