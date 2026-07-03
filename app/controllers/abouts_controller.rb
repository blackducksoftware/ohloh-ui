# frozen_string_literal: true

class AboutsController < ApplicationController
  before_action :tool_context, only: :tools

  def tools
    @languages = Language.order('nice_name')
    @languages_total_sum = @languages.inject(0) { |a, e| a + e.total }
    render 'abouts/tools'
  end
end
