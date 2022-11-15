$(document).ready(function(){
  scanDataFetch()
});
function scanDataFetch(){
  $.ajax({
    type: 'GET',
    url: '/p/' + $('#chart_data').data('project-id') + '/scan_analytics/charts?scan_id=' + $('#chart_data').data('scan-project-id'),
    success: function(data) {
      var options = {
        chart: {
          zoomType: 'xy'
        },
      };
      setDefaultChartOptions()
      outstandingFixedChart(options, data)
      defectDensityChart(options, data)
      highImpactChart(options, data)
      mediumImpactChart(options, data)
    }
  });
}

function setDefaultChartOptions() {
  Highcharts.setOptions({
    title: {
      style: {
        color: '#000',
        font: 'bold 14px "Helvetica Neue",Helvetica,Arial,sans-serif'
      }
    },
    xAxis: {
      labels: {
        style: {
          color: '#606064',
          font: '8px Helvetica Neue",Helvetica,Arial,sans-serif'
        }
      },
      title: {
        style: {
          color: '#333',
          fontWeight: 'bold',
          fontSize: '12px',
          fontFamily: 'Helvetica Neue",Helvetica,Arial,sans-serif'

        }
      }
    },
    yAxis: {
      lineWidth: 0,
      tickWidth: 0,
      labels: {
        style: {
          color: '#606064',
          font: '11px Helvetica Neue",Helvetica,Arial,sans-serif'
        }
      },
      title: {
        style: {
          color: '#333',
          fontWeight: 'bold',
          fontSize: '12px',
          fontFamily: 'Helvetica Neue",Helvetica,Arial,sans-serif'
        }
      }
    },
    legend: {
      itemHoverStyle: {
        color: '#039'
      },
      itemHiddenStyle: {
        color: 'gray'
      }
    },
    credits: {
      style: {
        right: '10px'
      }
    },
    labels: {
      style: {
        color: '#99b'
      }
    }
  });
}

function outstandingFixedChart(options, data){
  if (data && data['fixed_defects']){
    var chart1Options = {
    chart: {
      renderTo: 'chart1',
      type: 'line',
    },
    title: {
      text: 'Outstanding vs Fixed defects over period of time'
    },
    xAxis: {
      categories: Object.entries(data['fixed_defects']).map(function(m){return m[0]})
    },
    legend: {
      align: 'right',
      verticalAlign: 'top',
      layout: 'vertical',
      x: 0,
      y: 100
    },
    yAxis: {
      title: {
        text: null
      }
    },
    series: [{
      name: 'Fixed defects',
      data: Object.entries(data['fixed_defects']),
      color: '#7CB5EC'
    },{
      name: 'Outstanding defects',
      data: Object.entries(data['outstanding_defects']),
      color: '#FF5733'
    }]
  };
    chart1Options = jQuery.extend(true, {}, options, chart1Options);
    new Highcharts.Chart(chart1Options);
  }
}

function defectDensityChart(options, data) {
  if (data && data['defect_density']){
    var chart2Options = {
      chart: {
        renderTo: 'chart2',
        type: 'line',
      },
      title: {
        text: 'Defect Density over period of time'
      },
      legend: {
        align: 'right',
        verticalAlign: 'top',
        layout: 'vertical',
        x: 0,
        y: 100
      },
      yAxis: {
        title: {
          text: null
        }
      },
      xAxis: {
        categories: Object.entries(data['defect_density'][0].data).map(function(m){return m[0]})
      },
      series: [{
        name: data['defect_density'] ? data['defect_density'][0].name : null,
        data: data['defect_density'] ? Object.entries(data['defect_density'][0].data) : [],
        color: '#7CB5EC'
      }]
    };
    chart2Options = jQuery.extend(true, {}, options, chart2Options);
    new Highcharts.Chart(chart2Options);
  }
}

function highImpactChart(options, data) {
  if (data && data['high_impact_defects']){
    var chart3Options = {
    chart: {
      renderTo: 'chart3',
      type: 'bar',
    },
    title: {
      text: 'High impact Outstanding Defect per Category'
    },
    legend: {
      enabled: false
    },
    series: [{
      color: '#800000',
      name: 'Value',
      data: Object.entries(data['high_impact_defects'])    
    }],
    xAxis: {
      type: 'category',
      title: {
        text: 'Defect Category'
      }
    },
    yAxis: {
      title: {
        text: 'Outstanding defects'
      }
    }
  };
    chart3Options = jQuery.extend(true, {}, options, chart3Options);
    new Highcharts.Chart(chart3Options);
  }
}

function mediumImpactChart(options, data) {
  if (data && data['medium_impact_defects']){
    var chart4Options = {
    chart: {
      renderTo: 'chart4',
        type: 'bar',
    },
    title: {
      text: 'Medium impact Outstanding Defect per Category'
    },
    legend: {
      enabled: false
    },
    series: [{
      name: 'Value',
      data: Object.entries(data['medium_impact_defects']),
      color: '#F7A35C'
    }],
    xAxis: {
      type: 'category',
      title: {
        text: 'Defect Category'
      }
    },
    yAxis: {
      title: {
        text: 'Outstanding defects'
      }
    },
  };
    chart4Options = jQuery.extend(true, {}, options, chart4Options);
    new Highcharts.Chart(chart4Options);
  }
}
