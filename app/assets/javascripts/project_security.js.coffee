ProjectVulnerabilityVersionChart =
  init: () ->
    return if $('#vulnerability_version_chart').length == 0

    $.ajax
      url: $('#vulnerability_version_chart').data('src')
      cache: false
      success: (data) ->
        return if (data == null)
        chart = new Highcharts.Chart(data);

$(document).on 'page:change', ->
  ProjectVulnerabilityVersionChart.init()
