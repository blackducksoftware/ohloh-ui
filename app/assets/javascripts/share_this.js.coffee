ShareThis =
  init: ()->
    addthis_config =
      data_ga_property: $("#addthis_sharing").data("analytics-id")
      data_ga_social: true
      data_track_clickback: false

$(document).ready () ->
  $.getScript('//s7.addthis.com/js/300/addthis_widget.js#pubid=xa-500d3ed2408ee3c1')
  ShareThis.init()
