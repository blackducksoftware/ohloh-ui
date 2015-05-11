ProjectDemographics =
  init: () ->
    return if $('#project_demographics').length == 0

    $.ajax
      url: $('#demographics_chart').data('src')
      cache: false
      success: (data) ->
        return if (data == null)
        chart = new Highcharts.Chart(data);
        ProjectDemographics.tooltip_formatter(chart)

  tooltip_formatter: (chart) ->
    chart.tooltip.options.formatter = () ->
      if this.point.name
        "#{this.point.name}: #{this.y}%"
      else
        "#{this.series.name}: #{this.y}%"

$ ->
  ProjectDemographics.init()
