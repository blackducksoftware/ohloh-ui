require 'phusion_passenger'

class HomeController < ApplicationController
  def index
    @home = HomeDecorator.new
  end

  def server_info
    render json: { status: 'OK', ruby: RUBY_VERSION, rails: Rails.version,
                   git_sha: git_sha, passenger: PhusionPassenger::VERSION_STRING }
  end

  private

  def git_sha
    file = "#{Rails.root}/config/GIT_SHA"
    File.exists?(file) ? File.read(file)[0...40] : 'development'
  end
end
