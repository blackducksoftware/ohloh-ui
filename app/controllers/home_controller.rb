class HomeController < ApplicationController
  def index
    @home = HomeDecorator.new
  end

  def server_info
    render json: { status: 'OK', ruby: RUBY_VERSION, rails: Rails.version, environment: Rails.env,
                   git_sha: Rails.application.config.git_sha, passenger: Rails.application.config.passenger_version }
  end
end
