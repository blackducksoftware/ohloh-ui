# frozen_string_literal: true

class CspViolationReportsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def report
    notify_airbrake(request.raw_post)
    head :ok
  end
end
