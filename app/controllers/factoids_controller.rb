# frozen_string_literal: true

class FactoidsController < ApplicationController
  helper ProjectsHelper

  before_action :set_project_or_fail
  before_action :find_factoids
  before_action :project_context

  private

  def find_factoids
    @factoids = @project.best_analysis.factoids.reject { |f| f.type.to_s =~ /Distribution|Staff/ }
  end
end
