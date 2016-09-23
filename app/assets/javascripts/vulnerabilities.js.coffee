getReleaseData = () ->
  releaseObjects = document.getElementById('release_version').dataset.releases
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

reRenderChart = (releases) ->
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

$("#one").on 'click', ->
  releaseData = getReleaseData()
  yearDiff = $("#one").attr('date')
  filteredReleases = filterByDate(releaseData, yearDiff)
  reRenderChart(filteredReleases)

$("#three").on 'click', ->
  releaseData = getReleaseData()
  yearDiff = $("#three").attr('date')
  filteredReleases = filterByDate(releaseData, yearDiff)
  reRenderChart(filteredReleases)

$("#five").on 'click', ->
  releaseData = getReleaseData()
  yearDiff = $("#five").attr('date')
  filteredReleases = filterByDate(releaseData, yearDiff)
  reRenderChart(filteredReleases)

$("#ten").on 'click', ->
  releaseData = getReleaseData()
  yearDiff = $("#ten").attr('date')
  filteredReleases = filterByDate(releaseData, yearDiff)
  reRenderChart(filteredReleases)

$("#all").on 'click', ->
  releaseData = getReleaseData()
  reRenderChart(releaseData)

$('#release_version').on 'change', ->
  selVal = $('#release_version').val()
  releaseData = getReleaseData()
  filteredReleases = releaseData.filter((item) ->
    ///^#{selVal}///.test item.version
  )
  reRenderChart(filteredReleases)
