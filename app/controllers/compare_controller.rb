class CompareController < ApplicationController
  helper ProjectsHelper
  helper RatingsHelper

  def projects
    @projects = [Project.where(name: params[:project_0]).first,
                 Project.where(name: params[:project_1]).first,
                 Project.where(name: params[:project_2]).first]
  end
end
