ShareThis =
  init: ()->
    addthis_config =
      data_ga_property: $("#addthis_sharing").data("analytics-id")
      data_ga_social: true
      data_track_clickback: false
