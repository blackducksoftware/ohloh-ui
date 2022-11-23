App.ScanAnalytics =
  init: ->
    $('#scan_data_row > .project_row').slick
      arrows: false
      speed: 900
      infinite: true
      slidesToShow: 1
      slidesToScroll: 1
      autoplay: true
      autoplaySpeed: 10000
      dots: true
      adaptiveHeight: true
    if $('#scan_data').length > 0
      scanDataFetch()
      $('#scan_data').on 'ajax:before', ->
        $('.overlay-loader').show()

scanDataFetch = ->
  $.ajax
    type: 'GET'
    url: '/p/' + $('#chart_data').data('project-id') + '/scan_analytics/charts?code_set_id=' + $('#chart_data').data('code-set-id')
    success: (data) ->
      options = chart: zoomType: 'xy'
      setDefaultChartOptions()
      outstandingFixedChart options, data
      defectDensityChart options, data
      highImpactChart options, data
      mediumImpactChart options, data

setDefaultChartOptions = ->
  Highcharts.setOptions
    title: style:
      color: '#000'
      font: 'bold 14px "Helvetica Neue",Helvetica,Arial,sans-serif'
    xAxis:
      labels: style:
        color: '#606064'
        font: '8px Helvetica Neue",Helvetica,Arial,sans-serif'
      title: style:
        color: '#333'
        fontWeight: 'bold'
        fontSize: '12px'
        fontFamily: 'Helvetica Neue",Helvetica,Arial,sans-serif'
    yAxis:
      lineWidth: 0
      tickWidth: 0
      labels: style:
        color: '#606064'
        font: '11px Helvetica Neue",Helvetica,Arial,sans-serif'
      title: style:
        color: '#333'
        fontWeight: 'bold'
        fontSize: '12px'
        fontFamily: 'Helvetica Neue",Helvetica,Arial,sans-serif'
    legend:
      itemHoverStyle: color: '#039'
      itemHiddenStyle: color: 'gray'
    credits: style: right: '10px'
    labels: style: color: '#99b'

outstandingFixedChart = (options, data) ->
  if data and data['fixed_defects']
    chart1Options = 
      chart:
        renderTo: 'chart1'
        type: 'line'
      title: text: 'Outstanding vs Fixed defects over period of time'
      xAxis: categories: Object.entries(data['fixed_defects']).map((m) ->
        m[0]
      )
      legend:
        align: 'right'
        verticalAlign: 'top'
        layout: 'vertical'
        x: 0
        y: 100
        width: 100
        itemStyle : '{ "word-wrap": "break-word"}'
      yAxis: title: text: null
      series: [
        {
          name: 'Fixed defects'
          data: Object.entries(data['fixed_defects'])
          color: '#7CB5EC'
        }
        {
          name: 'Outstanding defects'
          data: Object.entries(data['outstanding_defects'])
          color: '#FF5733'
        }
      ]
    chart1Options = jQuery.extend(true, {}, options, chart1Options)
    new (Highcharts.Chart)(chart1Options)

defectDensityChart = (options, data) ->
  if data and data['defect_density']
    chart2Options =
      chart:
        renderTo: 'chart2'
        type: 'line'
      title: text: 'Defect Density over period of time'
      legend:
        align: 'right'
        verticalAlign: 'top'
        layout: 'vertical'
        x: 0
        y: 100
        width: 100
        itemStyle : '{ "word-wrap": "break-word"}'
      plotOptions: series: connectNulls: true
      yAxis: title: text: null
      xAxis:
        categories: Object.entries(data['defect_density'][0].data).map((m) ->
          m[0]
        )
        title: text: if data['defect_density_title'] then data['defect_density_title'] else null
      series: [
        {
          name: if data['defect_density'][0] then data['defect_density'][0].name else null
          data: if data['defect_density'][0] then Object.entries(data['defect_density'][0].data).map( (a) -> if a[1] == null then a[1] else a[1] = +a[1]
          ) else []
          color: '#7CB5EC'
        }
        {
          name: if data['defect_density'][1] then data['defect_density'][1].name else null
          data: if data['defect_density'][1] then Object.entries(data['defect_density'][1].data).map( (a) -> if a[1] == null then a[1] else a[1] = +a[1]
          ) else []
          color: '#FF5733'
        }
      ]
    chart2Options = jQuery.extend(true, {}, options, chart2Options)
    new (Highcharts.Chart)(chart2Options)

highImpactChart = (options, data) ->
  if data and Object.keys(data["high_impact_defects"]).length > 0
    chart3Options = 
      chart:
        renderTo: 'chart3'
        type: 'bar'
      title: text: 'High impact Outstanding Defect per Category'
      legend: enabled: false
      series: [ {
        color: '#800000'
        name: 'Value'
        data: Object.entries(data['high_impact_defects'])
      } ]
      xAxis:
        type: 'category'
        title: text: 'Defect Category'
      yAxis: title: text: 'Outstanding defects'
    chart3Options = jQuery.extend(true, {}, options, chart3Options)
    new (Highcharts.Chart)(chart3Options)

mediumImpactChart = (options, data) ->
  if data and Object.keys(data["medium_impact_defects"]).length > 0
    chart4Options = 
      chart:
        renderTo: 'chart4'
        type: 'bar'
      title: text: 'Medium impact Outstanding Defect per Category'
      legend: enabled: false
      series: [ {
        name: 'Value'
        data: Object.entries(data['medium_impact_defects'])
        color: '#F7A35C'
      } ]
      xAxis:
        type: 'category'
        title: text: 'Defect Category'
      yAxis: title: text: 'Outstanding defects'
    chart4Options = jQuery.extend(true, {}, options, chart4Options)
    new (Highcharts.Chart)(chart4Options)

$(document).ready ->
  App.ScanAnalytics.init()
