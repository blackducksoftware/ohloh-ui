CommitTimeline = {
  init: function() {
    tl_div = $('#timeline');
    if (tl_div.length == 0) { return; }

    var date = tl_div.attr('date');
    var project_id = tl_div.attr('project_id');
    var name_id = tl_div.attr('name_id');

    var eventSource = new Timeline.DefaultEventSource();
    var bandInfos = [
      Timeline.createBandInfo({
          eventSource:    eventSource,
          date:           date,
          width:          "70%",
          intervalUnit:   Timeline.DateTime.WEEK,
          intervalPixels: 200
      }),
      Timeline.createBandInfo({
        showEventText:  false,
        trackHeight:    0.5,
        trackGap:       0.2,
        eventSource:    eventSource,
        date:           date,
        width:          "20%",
        intervalUnit:   Timeline.DateTime.MONTH,
        intervalPixels: 150
      }),
      Timeline.createBandInfo({
        showEventText:  false,
        trackHeight:    0.5,
        trackGap:       0.2,
        eventSource:    eventSource,
        date:           date,
        width:          "10%",
        intervalUnit:   Timeline.DateTime.YEAR,
        intervalPixels: 120
      })
    ];
    bandInfos[1].syncWith = 0;
    bandInfos[1].highlight = true;
    bandInfos[1].eventPainter.setLayout(bandInfos[0].eventPainter.getLayout());

    bandInfos[2].syncWith = 0;
    bandInfos[2].highlight = true;
    bandInfos[2].eventPainter.setLayout(bandInfos[0].eventPainter.getLayout());

    tl = Timeline.create(tl_div[0], bandInfos);
    Timeline.loadXML("/p/" + project_id + "/commits/" + name_id + "/events?contributor_id="+name_id, function(xml, url) { eventSource.loadXML(xml, url); });

  }
}

$(document).on('page:change', function() {
  CommitTimeline.init();
});
