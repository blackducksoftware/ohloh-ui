getReleaseData = () ->
  releaseObjects = document.getElementById('vulnerability_filter_major_version').dataset.releases
  data = JSON.parse(releaseObjects)

calculateHighVulns = (releases) ->
  highVulns = releases.map((obj) ->
    obj.high_vulns.length
  )

calculateMediumVulns = (releaseData) ->
  mediumVulns = releaseData.map((obj) ->
    obj.medium_vulns.length
  )

calculateLowVulns = (releaseData) ->
  lowVulns = releaseData.map((obj) ->
    obj.low_vulns.length
  )

filterByDate = (releases, filter) ->
  endDate = new Date(releases[releases.length - 1].released_on)
  startDate = new Date(endDate.getFullYear() - filter, endDate.getMonth(), endDate.getDay(), endDate.getSeconds(), endDate.getMilliseconds())
  filteredReleases = releases.filter((item) ->
    time = new Date(item.released_on).getTime()
    startDate < time && time < endDate.getTime()
  )

renderNoData = (releases) ->
  chart = $('#vulnerability_version_chart').highcharts()
  renderer = new Highcharts.Renderer($('#vulnerability_version_chart')[0],10,10)
  reRenderChart(releases)
  chart.renderer.text('There are no reported vulnerabilities', 250, 70).css({fontSize: '12px'}).add()

reRenderChart = (releases) ->
  $('tspan').remove() if $('tspan').html() == "There are no reported vulnerabilities"
  versions = releases.map((obj) ->
    obj.version
  )
  chart = $('#vulnerability_version_chart').highcharts()
  chart.xAxis[0].update {
    categories: versions
  } , true, false
  chart.series[2].update {
    data: calculateHighVulns(releases)
  }, false
  chart.series[1].update {
    data: calculateMediumVulns(releases)
  }, false
  chart.series[0].update { 
    data: calculateLowVulns(releases)
  }, false
  chart.redraw()

$('.release_timespan').click ->
  return if $(this).hasClass('selected')
  yearDiff = $(this).attr('date')
  $('#vulnerability_filter_period').val(yearDiff)
  $('#vulnerability_filter_period').trigger('change')
  $('.release_timespan').removeClass('selected')
  $(this).addClass('selected')
  releaseData = getReleaseData()
  if yearDiff == ''
    filteredReleases = releaseData
  else
    filteredReleases = filterByDate(releaseData, yearDiff)
  if filteredReleases.length == 0
    renderNoData(filteredReleases)
  else
    reRenderChart(filteredReleases)

$('#vulnerability_filter_major_version').on 'change', ->
  selVal = $('#vulnerability_filter_major_version').val()
  releaseData = getReleaseData()
  filteredReleases = releaseData.filter((item) ->
    ///^#{selVal}///.test item.version
  )
  reRenderChart(filteredReleases)

highlightReleaseTimespan = () ->
  yearDiff = $('#vulnerability_filter_period').val()
  $('.release_timespan[date="' + yearDiff + '"]').addClass('selected')

$(document).on 'page:change', ->
  highlightReleaseTimespan()
