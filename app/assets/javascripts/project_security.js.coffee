ProjectVulnerabilityVersionChart =
  init: () ->
    return if $('#vulnerability_version_chart').length == 0

    $.ajax
      url: $('#vulnerability_version_chart').data('src')
      cache: false
      success: (data) ->
        return if (data == null)
        extendChartOptions(data)
        chart = new Highcharts.Chart(data)
        if $('#vulnerability_version_chart').parents('#vulnerabilities_index_page').length > 0
          reDrawVulnerabilityChart()

ProjectVulnerabilityFilter =
  init: () ->
    this.mainFilter(this)
    this.filter(this)
    this.reloadPageOnHistoryNavigation()

  mainFilter: (_klass) ->
    $('#vulnerabilities_index_page').on 'change', '.vulnerability_main_filter', (event) ->
      queryStr = filter:
        major_version: $('#vulnerability_filter_major_version').val()
        period: $('#vulnerability_filter_period').val()
      projectUrl = getProjectUrl()
      $.ajax
        url: projectUrl.concat('vulnerabilities_filter'),
        data: queryStr
        success: (vulTable) ->
          window.history.pushState('', document.title, projectUrl + 'security?' + $.param(queryStr))
          $('#vulnerabilities-data').html(vulTable)

  filter: (_klass) ->
    $('#vulnerabilities_index_page').on 'change', '.vulnerability_filter', (event) ->
      queryStr = filter:
        major_version: $('#vulnerability_filter_major_version').val()
        period: $('#vulnerability_filter_period').val()
        version: $('#vulnerability_filter_version').val()
        severity: $('#vulnerability_filter_severity').find(':selected').val()
      projectUrl = getProjectUrl()
      $.ajax
        url: projectUrl.concat('vulnerabilities_filter'),
        data: queryStr
        success: (vulTable) ->
          window.history.pushState('', document.title, projectUrl + 'security?' + $.param(queryStr))
          $('#vulnerabilities-data').html(vulTable)

  reloadPageOnHistoryNavigation: () ->
    window.addEventListener 'popstate', (event) ->
      window.location.reload()

@getProjectUrl = () ->
  window.location.href.match(/\/p\/.+\//)[0]

extendChartOptions = (options) ->
  return if $('#vulnerability_version_chart').parents('#vulnerabilities_index_page').length == 0
  options.plotOptions['series'] =
    cursor: 'pointer'
    point:
      events:
        click: (event) ->
          queryStr = filter:
            version: find_release_by_version(this.category).id
          projectUrl = getProjectUrl()
          $.ajax
            url: projectUrl.concat('vulnerabilities_filter'),
            data: queryStr
            success: (vulTable) ->
              window.history.pushState('', document.title, projectUrl + 'security?' + $.param(queryStr))
              $('#vulnerabilities-data').html(vulTable)



ProjectVulnerabilitySort =
  init: () ->
    this.sortButtonUpdate(this)

  sortButtonUpdate: (_klass) ->
    $('#vulnerabilities_index_page').on 'click', '.vulnerability_sort_btn i', (event) ->
      if $(this).hasClass('disable')
        sortDirection = $(this).data('direction')
      else
        sortDirection = $(this).siblings().data('direction')
      queryStr =
               filter:
                 major_version: $('#vulnerability_filter_major_version').val()
                 period: $('#vulnerability_filter_period').val()
                 version: $('#vulnerability_filter_version').val()
                 severity: $('#vulnerability_filter_severity').find(':selected').val()
               sort:
                 col: $(this).parents('.vulnerability_sort_btn').data('source')
                 direction: sortDirection
      projectUrl = getProjectUrl()
      $.ajax
        url: projectUrl.concat('vulnerabilities_filter'),
        data: queryStr
        success: (vulTable) ->
          window.history.pushState('', document.title, projectUrl + 'security?' + $.param(queryStr))
          $('#vulnerabilities-data').html(vulTable)
      return false


ProjectVulnerabilityPagination =
  init: () ->
    this.ajaxPagination(this)

  ajaxPagination: (_klass) ->
    $('#vulnerabilities_index_page').on 'click', '.pagination a', (event) ->
      projectUrl = getProjectUrl()
      queryStr = $(this).attr('href').split('?')[1]
      remote_url = $(this).attr('href')
      $.ajax
        url: remote_url,
        success: (vulTable) ->
          window.history.pushState('', document.title, projectUrl + 'security?' + queryStr)
          $('#vulnerabilities-data').html(vulTable)
      return false


$(document).on 'page:change', ->
  ProjectVulnerabilityVersionChart.init()
  ProjectVulnerabilityFilter.init()
  ProjectVulnerabilitySort.init()
  ProjectVulnerabilityPagination.init()
  $('#vulnerabilities_index_page').on 'click', 'tr.nvd_link', ->
    window.open($(this).data('nvd-link'), '_blank')

  $('#vulnerabilities_index_page').on 'click', 'span#read_more a, span#read_less a', (e) ->
    e.stopPropagation()
    $(this).closest('td').find('span').toggle()
