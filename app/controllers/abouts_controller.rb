class AboutsController < ApplicationController
  def tools
    @languages = Language.all.order('nice_name')
    @languages_total_sum = @languages.inject { |a, e| a + e.total }
    render 'abouts/tools'
  end
end
