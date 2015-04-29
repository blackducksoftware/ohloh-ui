class HomeController < ApplicationController
  def index
    @home = HomeDecorator.new
  end

  def server_info
    render json: { status: 'OK', ruby: RUBY_VERSION, rails: Rails.version,
                   git_sha: HomeController.git_sha, passenger: HomeController.passenger_version }
  end

  class << self
    def git_sha
      file = "#{Rails.root}/config/GIT_SHA"
      File.exist?(file) ? File.read(file)[0...40] : 'development'
    end

    def passenger_version
      /([0-9\.]+)/.match(`passenger -v`)[0] rescue 'development'
    end
  end
end
