# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @home = HomeDecorator.new
  end
end
