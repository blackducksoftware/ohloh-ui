class CoverageController < ApplicationController
  def index
  end

  def show
    eval 'a = 12'
  end
end
