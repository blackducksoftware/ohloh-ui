# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https:#github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require rails-ujs
# From active_admin -> jquery-rails # Using node_modules/jquery raises issues due to double jquery load.
#= require jquery3
#= require jquery/jquery-ui.min
#= require twitter/bootstrap
#= require underscore-min
#= require jquery/chosen.jquery.min
#= require highcharts/highstock
#= require highcharts/highcharts-more
#= require highcharts/solid-gauge
#= require highcharts/exporting
#= require app
#= require_tree .
#= require d3.min
#= require tagcloud
#= require ace-element.min
#= require tipso.min
#= require simplemde.min
#= require slick.min


$(document).on 'page:change', ->
  StackShow.init()
  Expander.init()
  PopupClose.init()
  OrganizationPictogram.init()
  GaugeProgress.init()
  OrgsFilter.init()
  Cocomo.init()
  new App.ProjectForm()
  new App.CheckAvailiability($('input.check-availability'))
  App.TagCloud.init()
  ProjectMap.init()

# Remove the following trigger when TurboLinks are re-enabled
$(document).ready ->
  $(document).trigger 'page:change'
