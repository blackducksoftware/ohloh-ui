$("#one").on 'click', ->
  chart = $('#vulnerability_version_chart').highcharts()
  releaseObjects = document.getElementById('release_version').dataset.releases
  releaseData = JSON.parse(releaseObjects)
  yearDiff = $("#one").attr('date')
  endDate = new Date(releaseData[0].released_on)
  startDate = new Date(endDate.getFullYear() - yearDiff, endDate.getMonth(), endDate.getDay(), endDate.getSeconds(), endDate.getMilliseconds())
  filteredReleases = releaseData.filter((item) ->
    time = new Date(item.released_on).getTime()
    startDate < time && time < endDate.getTime()
  )
  chart.xAxis[0].setCategories(calculateCategory(filteredReleases))
  chart.series[0].setData(calculateY(filteredReleases), calculateHighVulns(filteredReleases))
  chart.series[1].setData(calculateY(filteredReleases), calculateMediumVulns(filteredReleases))
  chart.series[2].setData(calculateY(filteredReleases), calculateLowVulns(filteredReleases))

$("#three").on 'click', ->
  chart = $('#vulnerability_version_chart').highcharts()
  releaseObjects = document.getElementById('release_version').dataset.releases
  releaseData = JSON.parse(releaseObjects)
  yearDiff = $("#three").attr('date')
  endDate = new Date(releaseData[0].released_on)
  startDate = new Date(endDate.getFullYear() - yearDiff, endDate.getMonth(), endDate.getDay(), endDate.getSeconds(), endDate.getMilliseconds())
  filteredReleases = releaseData.filter((item) ->
    time = new Date(item.released_on).getTime()
    startDate < time && time < endDate.getTime()
  )
  chart.xAxis[0].setCategories(calculateCategory(filteredReleases))
  chart.series[0].setData(calculateY(filteredReleases), calculateHighVulns(filteredReleases))
  chart.series[1].setData(calculateY(filteredReleases), calculateMediumVulns(filteredReleases))
  chart.series[2].setData(calculateY(filteredReleases), calculateLowVulns(filteredReleases))

$("#five").on 'click', ->
  chart = $('#vulnerability_version_chart').highcharts()
  releaseObjects = document.getElementById('release_version').dataset.releases
  releaseData = JSON.parse(releaseObjects)
  yearDiff = $("#five").attr('date')
  endDate = new Date(releaseData[0].released_on)
  startDate = new Date(endDate.getFullYear() - yearDiff, endDate.getMonth(), endDate.getDay(), endDate.getSeconds(), endDate.getMilliseconds())
  filteredReleases = releaseData.filter((item) ->
    time = new Date(item.released_on).getTime()
    startDate < time && time < endDate.getTime()
  )
  chart.xAxis[0].setCategories(calculateCategory(filteredReleases))
  chart.series[0].setData(calculateY(filteredReleases), calculateHighVulns(filteredReleases))
  chart.series[1].setData(calculateY(filteredReleases), calculateMediumVulns(filteredReleases))
  chart.series[2].setData(calculateY(filteredReleases), calculateLowVulns(filteredReleases))

$("#ten").on 'click', ->
  chart = $('#vulnerability_version_chart').highcharts()
  releaseObjects = document.getElementById('release_version').dataset.releases
  releaseData = JSON.parse(releaseObjects)
  yearDiff = $("#ten").attr('date')
  endDate = new Date(releaseData[0].released_on)
  startDate = new Date(endDate.getFullYear() - yearDiff, endDate.getMonth(), endDate.getDay(), endDate.getSeconds(), endDate.getMilliseconds())
  filteredReleases = releaseData.filter((item) ->
    time = new Date(item.released_on).getTime()
    startDate < time && time < endDate.getTime()
  )
  chart.xAxis[0].setCategories(calculateCategory(filteredReleases))
  chart.series[0].setData(calculateY(filteredReleases), calculateHighVulns(filteredReleases))
  chart.series[1].setData(calculateY(filteredReleases), calculateMediumVulns(filteredReleases))
  chart.series[2].setData(calculateY(filteredReleases), calculateLowVulns(filteredReleases))
  
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

$('#release_version').on 'change', ->
  chart = $('#vulnerability_version_chart').highcharts()
  selVal = $('#release_version').val()
  releaseHtmlSelector = document.getElementById('release_version')
  releaseObjects = releaseHtmlSelector.dataset.releases
  filteredReleases = JSON.parse(releaseObjects).filter((item) ->
    ///^#{selVal}///.test item.version
  )
  chart.xAxis[0].setCategories(calculateCategory(filteredReleases))
  chart.series[0].setData(calculateY(filteredReleases), calculateHighVulns(filteredReleases))
  chart.series[1].setData(calculateY(filteredReleases), calculateMediumVulns(filteredReleases))
  chart.series[2].setData(calculateY(filteredReleases), calculateLowVulns(filteredReleases))
  