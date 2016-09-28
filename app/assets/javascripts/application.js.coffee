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
#= require jquery
#= require jquery_ujs
#= require jquery-ui
#= require underscore-min
#= require chosen.jquery.min
#= require highcharts/highstock
#= require highcharts/highcharts-more
#= require highcharts/solid-gauge
#= require app
#= require_tree .
#= require twitter/bootstrap
#= require d3.min
#= require tagcloud
#= require ace-element.min
#= require tipso.min

$(document).on 'page:change', ->
  StackShow.init()
  Expander.init()
  PopupClose.init()
  OrganizationPictogram.init()
  GaugeProgress.init()
  OrgsFilter.init()
  Cocomo.init()
  new App.ProjectForm()
  OrgClaimProject.init()
  new App.CheckAvailiability($('input.check-availability'))
  App.TagCloud.init()

# Remove the following trigger when TurboLinks are re-enabled
$(document).ready ->
  $(document).trigger 'page:change'
