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

@find_release_by_id = (id) ->
  release = undefined
  id = parseInt(id)
  $.each getReleaseData(), (i, r) ->
    if r.id == id
      release = r
      return false
  release

@getProjectUrl = () ->
  window.location.href.match(/\/p\/.+\//)[0]

@extendVulnerabilityChartOptions = (options) ->
  options.plotOptions['series'] =
    cursor: 'pointer'
    point:
      events:
        click: (event) ->
          currentRelease = find_release_by_version(this.category)
          oldReleaseId = parseInt $('#vulnerability_filter_version').val()
          loadCurrentRelease(currentRelease, oldReleaseId)

@reDrawVulnerabilityChart = () ->
  releases = filterReleases()
  if releases.length == 0
    renderNoData(releases)
  else
    reRenderChart(releases)

@refreshVulnerabilityTable = () ->
  releases = filterReleases().reverse()
  currentRelease = releases[0]
  unless currentRelease
    return noReportedVulnerabilities()
  oldReleaseId = parseInt $('#vulnerability_filter_version').val()
  updateVersionFilter(releases)
  loadCurrentRelease(currentRelease, oldReleaseId)

@fetchVulnerabilityData = (queryStr) ->
  $.ajax
    url: getProjectUrl().concat('vulnerabilities_filter')
    data: queryStr
    beforeSend: ->
      $('.overlay-loader').show()
    success: (vulTable) ->
      $('.vulnerabilities-datatable').html(vulTable)
      $('.overlay-loader').hide()

@updateSeverityFilter = (release) ->
  $('#vulnerability_filter_severity').prop('disabled', false)
  $.each ['low', 'medium', 'high', 'critical', 'unknown_severity'], (index, severity) ->
    $("#vulnerability_filter_severity option[value=#{severity}]").prop('disabled', release[severity] == 0 && release['bdsa_' + severity] == 0)

@updateBrowserHistory = (queryStr) ->
  if queryStr == undefined
    queryStr = filter:
      major_version: $('#vulnerability_filter_major_version').val()
      period: $('#vulnerability_filter_period').val()
      version: $('#vulnerability_filter_version').val()
      severity: $('#vulnerability_filter_severity').find(':selected').val()
      type: $('#vulnerability_filter_cve_id').find(':selected').val()
  window.history.pushState('', document.title, getProjectUrl() + 'security?' + $.param(queryStr))

filterReleases = () ->
  majorVersion = $('#vulnerability_filter_major_version').val()
  year = $('#vulnerability_filter_period').val()
  filteredReleases = filterReleasesByMajorVersion(getReleaseData(), majorVersion)
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
  # Temporary fix for Android
  if releases[0].version.match(/^android-\d+.\d+.r1|^android-\d+.\d+.\d_r1/i)
    releases.filter (release) ->
      ///^#{majorVersion}///.test(release.version)
  else
    releases.filter (release) ->
      ///^v?\.?#{majorVersion}+(?:\.\d+)+$///.test(release.version)

calculateCriticalVulns = (releases) ->
  criticalVulns = releases.map((obj) ->
    obj.critical
  )

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

calculateUnknownSeverityVulns = (releaseData) ->
  unknownVulns = releaseData.map((obj) ->
    obj.unknown_severity
  )

calculateBdsaCriticalVulns = (releases) ->  
  criticalVulns = releases.map((obj) ->
    obj.bdsa_critical
  )

calculateBdsaHighVulns = (releases) ->  
  highVulns = releases.map((obj) ->
    obj.bdsa_high
  )

calculateBdsaMediumVulns = (releaseData) ->
  mediumVulns = releaseData.map((obj) ->
    obj.bdsa_medium
  )

calculateBdsaLowVulns = (releaseData) ->
  lowVulns = releaseData.map((obj) ->
    obj.bdsa_low
  )

calculateBdsaUnknownSeverityVulns = (releaseData) ->
  unknownVulns = releaseData.map((obj) ->
    obj.bdsa_unknown_severity
  )

renderNoData = (releases) ->
  chart = $('#vulnerability_all_version_chart').highcharts()
  renderer = new Highcharts.Renderer($('#vulnerability_all_version_chart')[0],10,10)
  reRenderChart(releases)
  chart.renderer.text('There are no reported vulnerabilities', 450, 70).css({fontSize: '12px'}).add()

reRenderChart = (releases) ->
  $('tspan').remove() if $('tspan').html() == "There are no reported vulnerabilities"
  versions = releases.map((obj) ->
    obj.version
  )
  chart = $('#vulnerability_all_version_chart').highcharts()
  chart.xAxis[0].update {
    categories: versions
  } , true, false
  chart.series[0].update {
    data: calculateCriticalVulns(releases)
  }, false
  chart.series[1].update {
    data: calculateHighVulns(releases)
  }, false
  chart.series[2].update {
    data: calculateMediumVulns(releases)
  }, false
  chart.series[3].update {
    data: calculateLowVulns(releases)
  }, false
  chart.series[4].update {
    data: calculateUnknownSeverityVulns(releases)
  }, false
  if $('select#vulnerability_filter_major_version').data('bdsa-visible') == true
    chart.series[5].update {
      data: calculateBdsaCriticalVulns(releases)
    }, false
    chart.series[6].update {
      data: calculateBdsaHighVulns(releases)
    }, false
    chart.series[7].update {
      data: calculateBdsaMediumVulns(releases)
    }, false
    chart.series[8].update {
      data: calculateBdsaLowVulns(releases)
    }, false
    chart.series[9].update {
      data: calculateBdsaUnknownSeverityVulns(releases)
    }, false
  chart.redraw()

noReportedVulnerabilities = () ->
  $('#vulnerability_filter_version').html("<option value=''>No versions in specified filters</option>")
  $('#vulnerability_filter_severity').prop('disabled', true)
  $('.vulnerabilities-datatable').html('<div class="no_vulnerability">There are no reported vulnerabilities</div>')
  queryStr = filter:
    major_version: $('#vulnerability_filter_major_version').val()
    period: $('#vulnerability_filter_period').val()
  updateBrowserHistory(queryStr)

loadCurrentRelease = (currentRelease, oldReleaseId) ->
  if currentRelease.id == oldReleaseId
    updateBrowserHistory()
  else
    $('#vulnerability_filter_version').val(currentRelease.id).change()

updateVersionFilter = (releases) ->
  releases_option = releases.map((release) ->
    "<option value=#{release.id}>#{release.version}</option>"
  ).join('')
  $('#vulnerability_filter_version').html(releases_option)
