redrawGraph = (releases) ->
  options.xAxis = categories: calculateCategory(releases)
  options.series = [
    {
      name: 'High Severity'
      data: calculateY(releases, calculateHighVulns(gon.releases))
      color: '#4586BE'
    }
    {
      name: 'Medium Severity'
      data: calculateY(releases, calculateMediumVulns(gon.releases))
      color: '#64AAF1'
    }
    {
      name: 'Low Severity'
      data: calculateY(releases, calculateLowVulns(gon.releases))
      color: '#9DC7F1'
    }
  ]
  chart = new (Highcharts.Chart)(options)

calculateCategory = (releases) ->
  labels = []
  releases.forEach (item) ->
    labels.push item.version
  labels

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
    index = gon.releases.indexOf(item)
    indices.push index
  indices.forEach (idx) ->
    yData.push vulnData[idx]
  yData

options =
  credits:
    enabled: false
  chart:
    type: 'column'
    renderTo: 'container'
    zoomType: 'x'
    events: load: ->
      label = @renderer.label('click and drag to zoom').css(width: '180px').attr(
        'r': 5
        'padding': 10).add()
      label.align Highcharts.extend(label.getBBox(),
        align: 'right'
        x: 0
        verticalAlign: 'top'
        y: 30), null, 'spacingBox'
      return
  title: text: null
  xAxis: categories: calculateCategory(gon.releases)
  yAxis:
    min: 0
    allowDecimals: false
    title: text: 'Vulnerabilities'
    stackLabels:
      enabled: false
      style:
        fontWeight: 'bold'
        color: Highcharts.theme and Highcharts.theme.textColor or 'gray'
  tooltip:
    headerFormat: '<b>{point.x}</b><br/>'
    pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}'
  plotOptions:
    series:
      pointWidth: 10
      pointPadding: .1
    column:
      stacking: 'normal'
      dataLabels:
        enabled: false
        color: Highcharts.theme and Highcharts.theme.dataLabelsColor or 'white'
        style: textShadow: '0 0 3px black'
  series: [
    {
      name: 'High Severity'
      data: calculateHighVulns(gon.releases)
      color: '#4586BE'
    }
    {
      name: 'Medium Severity'
      data: calculateMediumVulns(gon.releases)
      color: '#64AAF1'
    }
    {
      name: 'Low Severity'
      data: calculateLowVulns(gon.releases)
      color: '#9DC7F1'
    }
]

chart = new (Highcharts.Chart)(options)

$("#one").on 'click', ->
  yearDiff = $("#one").attr('date')
  endDate = new Date(gon.releases.slice(-1)[0].released_on)
  startDate = new Date(endDate.getFullYear() - yearDiff, endDate.getMonth(), endDate.getDay(), endDate.getSeconds(), endDate.getMilliseconds())
  releases = gon.releases.filter((item) ->
    time = new Date(item.released_on).getTime()
    startDate < time && time < endDate.getTime()
  )
  redrawGraph(releases)

$("#three").on 'click', ->
  yearDiff = $("#three").attr('date')
  endDate = new Date(gon.releases.slice(-1)[0].released_on)
  startDate = new Date(endDate.getFullYear() - yearDiff, endDate.getMonth(), endDate.getDay(), endDate.getSeconds(), endDate.getMilliseconds())
  releases = gon.releases.filter((item) ->
    time = new Date(item.released_on).getTime()
    startDate < time && time < endDate.getTime()
  )
  redrawGraph(releases)

$("#five").on 'click', ->
  yearDiff = $("#five").attr('date')
  endDate = new Date(gon.releases.slice(-1)[0].released_on)
  startDate = new Date(endDate.getFullYear() - yearDiff, endDate.getMonth(), endDate.getDay(), endDate.getSeconds(), endDate.getMilliseconds())
  releases = gon.releases.filter((item) ->
    time = new Date(item.released_on).getTime()
    startDate < time && time < endDate.getTime()
  )
  redrawGraph(releases)

$("#ten").on 'click', ->
  yearDiff = $("#ten").attr('date')
  endDate = new Date(gon.releases.slice(-1)[0].released_on)
  startDate = new Date(endDate.getFullYear() - yearDiff, endDate.getMonth(), endDate.getDay(), endDate.getSeconds(), endDate.getMilliseconds())
  releases = gon.releases.filter((item) ->
    time = new Date(item.released_on).getTime()
    startDate < time && time < endDate.getTime()
  )
  redrawGraph(releases)

$("#all").on 'click', ->
  redrawGraph(gon.releases)

$('#release_version').on 'change', ->
  selVal = $('#release_version').val()
  if selVal == 'All'
    chart.series[0].setData(calculateHighVulns(gon.releases))
    chart.series[1].setData(calculateMediumVulns(gon.releases))
    chart.series[2].setData(calculateLowVulns(gon.releases))
  releases = gon.releases.filter((item) ->
    ///^#{selVal}///.test item.version
  )
  redrawGraph(releases)
