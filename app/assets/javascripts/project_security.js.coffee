ProjectVulnerabilityVersionChart =
  init: () ->
    return if $('#vulnerability_version_chart').length == 0

    $.ajax
      url: $('#vulnerability_version_chart').data('src')
      cache: false
      success: (data) ->
        return if (data == null)
        new Highcharts.Chart(data)

ProjectVulnerabilityAllVersionChart =
  init: () ->
    if $('#vulnerability_all_version_chart').length
      chartOptions = $('#vulnerability_all_version_chart').data('chart')
      extendVulnerabilityChartOptions(chartOptions)
      new Highcharts.Chart(chartOptions)
      reDrawVulnerabilityChart()

ProjectVulnerabilityFilter =
  init: () ->
    this.mainFilter(this)
    this.filter(this)
    this.reloadPageOnHistoryNavigation()

  mainFilter: (_klass) ->
    $('#vulnerabilities_index_page').on 'change', '.vulnerability_main_filter', (event) ->
      refreshVulnerabilityTable()

    $('#vulnerability_filter_major_version').on 'change', ->
      reDrawVulnerabilityChart()

    $('.release_timespan').click ->
      return if $(this).hasClass('selected')
      $('#vulnerability_filter_period').val($(this).attr('date')).change()
      reDrawVulnerabilityChart()
      $('.release_timespan').removeClass('selected')
      $(this).addClass('selected')

  filter: (_klass) ->
    $('#vulnerabilities_index_page').on 'change', '.vulnerability_filter', (event) ->
      queryStr = filter:
        version: $('#vulnerability_filter_version').val()
        severity: $('#vulnerability_filter_severity :selected').val()
        type: $('#vulnerability_filter_cve_id :selected').val()
      currentRelease = find_release_by_id(queryStr.filter.version)
      updateBrowserHistory()
      updateSeverityFilter(currentRelease)
      fetchVulnerabilityData(queryStr)

  reloadPageOnHistoryNavigation: () ->
    window.addEventListener 'popstate', (event) ->
      window.location.reload()

ProjectVulnerabilitySort =
  init: () ->
    $('#vulnerabilities_index_page').on 'click', '.vulnerability_sort_btn i', (event) ->
      if $(this).hasClass('disable')
        sortDirection = $(this).data('direction')
      else
        sortDirection = $(this).siblings().data('direction')
      queryStr =
               filter:
                 version: $('#vulnerability_filter_version').val()
                 severity: $('#vulnerability_filter_severity').find(':selected').val()
                 type: $('#vulnerability_filter_cve_id').find(':selected').val()
               sort:
                 col: $(this).parents('.vulnerability_sort_btn').data('source')
                 direction: sortDirection
      updateBrowserHistory(queryStr)
      fetchVulnerabilityData(queryStr)
      return false


ProjectVulnerabilityPagination =
  init: () ->
    $('#vulnerabilities_index_page').on 'click', '.pagination a', (event) ->
      queryStr = $(this).attr('href').split('?')[1]
      window.history.pushState('', document.title, getProjectUrl() + 'security?' + queryStr)
      fetchVulnerabilityData(queryStr)
      return false

$(document).on 'page:change', ->
  ProjectVulnerabilityVersionChart.init()
  ProjectVulnerabilityAllVersionChart.init()
  ProjectVulnerabilityFilter.init()
  ProjectVulnerabilitySort.init()
  ProjectVulnerabilityPagination.init()

  $('#vulnerabilities_index_page').on 'click', 'span#read_more a, span#read_less a', (e) ->
    e.stopPropagation()
    $(this).closest('td').find('span').toggle()
