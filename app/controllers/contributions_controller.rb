class ContributionsController < ApplicationController
  #helper :positions

  before_filter :set_project
  before_filter :set_project
  #before_filter :set_sort_and_highlight, only: :index

  def show
  end

  def summary
  end

  def commits_spark
  end

  def commits_compound_spark
  end

  def near
  end

  private

  def set_contribution
    @contribution = @project.contributions.find(params[:id])
    rescuecue ActiveRecord::RecordNotFound
      @contribution = Contribution.find_contributor_indirectly(id: params[:id], project_id: params[:project_id])
    fail ParamRecordNotFound unless @contribution
  end

  def set_project
    @project = Project.from_param(params[:project_id]).first
    render 'projects/deleted' if @porject.deleted?
  end
end
