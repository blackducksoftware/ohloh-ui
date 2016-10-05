@getReleaseData = () ->
  releaseObjects = document.getElementById('vulnerability_filter_major_version').dataset.releases
  data = JSON.parse(releaseObjects)

@find_release_by_version = (version) ->
  release = undefined
  $.each getReleaseData(), (i, r) ->
    if r.version == version
      release = r
      return false
  release

calculateHighVulns = (releases) ->
  highVulns = releases.map((obj) ->
    obj.high
  )

calculateMediumVulns = (releaseData) ->
  mediumVulns = releaseData.map((obj) ->
    obj.medium
  )

calculateLowVulns = (releaseData) ->
  lowVulns = releaseData.map((obj) ->
    obj.low
  )

filterReleases = () ->
  majorVersion = $('#vulnerability_filter_major_version').val()
  filteredReleases = filterReleasesByMajorVersion(getReleaseData(), majorVersion)
  year = $('#vulnerability_filter_period').val()
  filteredReleases = filterReleasesByYear(filteredReleases, year)
  filteredReleases.sort (a, b) ->
    if a.released_on > b.released_on
      return 1
    if a.released_on < b.released_on
      return -1

filterReleasesByYear = (releases, year) ->
  return releases if year == ''
  currentDate = new Date()
  currentDate.setHours(0,0,0,0)
  pastDate = new Date()
  pastDate.setHours(0,0,0,0)
  pastDate.setFullYear(pastDate.getFullYear() - year)
  releases.filter (item) ->
    releasedDate = new Date(item.released_on)
    releasedDate.setHours(0,0,0,0)
    releasedDate <= currentDate && releasedDate >= pastDate

filterReleasesByMajorVersion = (releases, majorVersion) ->
  return releases if majorVersion == ''
  releases.filter (release) ->
    ///^#{majorVersion}[\.]///.test(release.version) || ///^#{majorVersion}$///.test(release.version)

@reDrawVulnerabilityChart = () ->
  releases = filterReleases()
  if releases.length == 0
    renderNoData(releases)
  else
    reRenderChart(releases)

renderNoData = (releases) ->
  chart = $('#vulnerability_version_chart').highcharts()
  renderer = new Highcharts.Renderer($('#vulnerability_version_chart')[0],10,10)
  reRenderChart(releases)
  chart.renderer.text('There are no reported vulnerabilities', 450, 70).css({fontSize: '12px'}).add()

reRenderChart = (releases) ->
  $('tspan').remove() if $('tspan').html() == "There are no reported vulnerabilities"
  versions = releases.map((obj) ->
    obj.version
  )
  chart = $('#vulnerability_version_chart').highcharts()
  chart.xAxis[0].update {
    categories: versions
  } , true, false
  chart.series[0].update {
    data: calculateHighVulns(releases)
  }, false
  chart.series[1].update {
    data: calculateMediumVulns(releases)
  }, false
  chart.series[2].update {
    data: calculateLowVulns(releases)
  }, false
  chart.redraw()

$('.release_timespan').click ->
  return if $(this).hasClass('selected')
  $('#vulnerability_filter_period').val($(this).attr('date'))
  $('#vulnerability_filter_period').trigger('change')
  reDrawVulnerabilityChart()
  $('.release_timespan').removeClass('selected')
  $(this).addClass('selected')

$('#vulnerability_filter_major_version').on 'change', ->
  reDrawVulnerabilityChart()
