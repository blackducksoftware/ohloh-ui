class HomeController < ApplicationController
  def index
    @home = HomeDecorator.new
  end
end
