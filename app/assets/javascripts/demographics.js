ProjectDemographics = {
  init: function() {
    if ($('#project_demographics').length == 0) return;

    $.ajax({ url: $("#demographics_chart").attr('datasrc'),
            success: function(data){
              if (data == null) return;
              var chart = new Highcharts.Chart(data);
              ProjectDemographics.tooltip_formatter(chart);
            }
        });
  },

  tooltip_formatter: function(chart) {
    chart.tooltip.options.formatter = function() {
      var s;
      if (this.point.name) {
        s = '' + this.point.name +': '+ this.y +'%';
      } else {
        s = ''+
        this.series.name +': '+ this.y+'%';
      }
      return s;
    }
  }
};
