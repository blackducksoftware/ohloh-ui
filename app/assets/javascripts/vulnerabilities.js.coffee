getReleaseData = () ->
  releaseObjects = document.getElementById('release_version').dataset.releases
  data = JSON.parse(releaseObjects)

reRenderChart = (releases) ->
  chart = $('#vulnerability_version_chart').highcharts()
  chart.xAxis[0].setCategories(calculateCategory(releases))
  chart.xAxis[0].setExtremes(0, releases.length - 1)
  chart.series[0].setData(calculateY(releases), calculateHighVulns(releases))
  chart.series[1].setData(calculateY(releases), calculateMediumVulns(releases))
  chart.series[2].setData(calculateY(releases), calculateLowVulns(releases))

filterByDate = (releases, filter) ->
  endDate = new Date(releases[releases.length - 1].released_on)
  startDate = new Date(endDate.getFullYear() - filter, endDate.getMonth(), endDate.getDay(), endDate.getSeconds(), endDate.getMilliseconds())
  filteredReleases = releases.filter((item) ->
    time = new Date(item.released_on).getTime()
    startDate < time && time < endDate.getTime()
  )
  
calculateCategory = (releases) ->
  labels = []
  releases.forEach (item) ->
    labels.push item.version
  JSON.parse(JSON.stringify(labels))

calculateHighVulns = (releases) ->
  highVulns = []
  releases.forEach (item) ->
    highVulns.push item.high_vulns
  highVulns

calculateMediumVulns = (releases) ->
  mediumVulns = []
  releases.forEach (item) ->
    mediumVulns.push item.medium_vulns
  mediumVulns

calculateLowVulns = (releases) ->
  lowVulns = []
  releases.forEach (item) ->
    lowVulns.push item.low_vulns
  lowVulns

calculateY = (releases, vulnData) ->
  indices = []
  yData = []
  releases.forEach (item) ->
    index = releases.indexOf(item)
    indices.push index
  indices.forEach (idx) ->
    yData.push vulnData[idx]

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
