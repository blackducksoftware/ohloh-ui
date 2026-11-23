ProjectDemographics =
  chart: null

  DESCRIPTIONS:
    'Inactive': 'No recent activity'
    'Very Low': 'Minimal activity'
    'Low': 'Low activity'
    'Moderate': 'Moderate activity'
    'High': 'High activity'
    'Very High': 'Very high activity'
    'New': 'Newly added project'

  init: () ->
    return if $('#demographics_chart').length == 0

    $.ajax
      url: $('#demographics_chart').data('src')
      cache: false
      success: (data) ->
        return if (data == null)
        data.tooltip ||= {}
        data.tooltip.formatter = () ->
          name = if @point?.name then @point.name else @series?.name or ''
          pct  = if @y? then @y else 0
          desc = ProjectDemographics.DESCRIPTIONS[name] or ''
          isMobile = window.innerWidth <= 768
          if isMobile
            "<span class='hc-tooltip-name'>#{name}</span><span class='hc-tooltip-value'>#{pct}%</span>"
          else
            descHtml = if desc then "<span class='hc-tooltip-desc'>#{desc}</span>" else ''
            "<span class='hc-tooltip-name'>#{name}</span>#{descHtml}<span class='hc-tooltip-value'>#{pct}%</span>"

        # On touch/mobile devices, disable allowPointSelect so tap shows tooltip
        # instead of triggering slice selection animation
        isTouch = 'ontouchstart' of window or navigator.maxTouchPoints > 0
        if isTouch
          data.plotOptions ||= {}
          data.plotOptions.pie ||= {}
          data.plotOptions.pie.allowPointSelect = false
          data.plotOptions.pie.stickyTracking = true

        ProjectDemographics.chart = new Highcharts.Chart(data)

  reflow: () ->
    ProjectDemographics.chart.reflow() if ProjectDemographics.chart

$(document).on 'page:change', ->
  ProjectDemographics.init()

$(window).on 'resize', ->
  ProjectDemographics.reflow()
