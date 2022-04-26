$(document).on('page:change', function() {
  Charts.init();
});

var Charts = {
  renderNoCommitsMessage: function(chart, style) {
    style = style || '';
    var p = '<p style='+ style +'>No commits available to display</p>';
    p += '<p class="clear_left"></p>';

    $(chart).before(p);
    $(chart).hide();
  },

  process_chunk:function(array, i){
    if(i == 0)
      Charts.renderPositionCharts(array)
    else
      setTimeout(function(){ Charts.renderPositionCharts(array) }, 1000);
  },

  renderPositionCharts: function (array){
    array.each(function() {
      var chart = $(this);
      var options = chart.data();
      var data = $.parseJSON(chart.attr('data-value'));
      if(options.pname) data.series.name = options.pname;
      Charts.renderChart(this, data, '200', options);
    });
  },

  renderChart: function(chart, data, textStatus, options) {
    if (data.noCommits) {
      Charts.renderNoCommitsMessage(chart, 'margin-left:20px');
      return;
    }

    if (data.warning) {
      var $div = $("<div />", {
        'class': "alert alert-info",
        text: data.warning
      });
      $(chart).before($div);
    }
    data = $.merge(data, options);
    for(var p in options) {
      if(data.hasOwnProperty(p)) {
        data[p] = $.merge(options[p], data[p]);
       } else {
        data[p] = options[p];
      }
    }

    if (data.xAxis) {
      $.extend(data.xAxis.labels, {formatter: function(){
        var first_day = new Date(this.value)
        var last_day = new Date(first_day.getFullYear(), first_day.getMonth()+1, 0);
        var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
        return '';
        // if (months.includes(this.value.split(' ')[0]))
          // return '<a href="/admin/accounts?commit=Filter&q[created_at_gteq_datetime]=' + first_day + '&q[created_at_lteq_datetime]=' + last_day + '" target="_blank">' +
                    // this.value + '</a>';
        // else
          // return '<a href="/admin/accounts?commit=Filter&q[created_at_gteq_datetime]=' + this.value + '&q[created_at_lteq_datetime]=' + this.value + '" target="_blank">' +
                    // this.value + '</a>';
      }});
    }
    data.chart.renderTo = chart;
    if (!data.tooltip) { data.tooltip = {}; }
    if (!options.tooltips) { options.tooltips = {}; }

    if( options.tooltips ) {
      if (data.tooltip.dateFormat) {
        data.tooltip.formatter = function() {
          if (data.title == "Commits" || "Committers") {
            if (this.points && this.points[0].series.name == "Current Month") {
              return "Partial " + Highcharts.dateFormat("%B", this.x) + "<br>" +
              "<span style=\"fill:#4572A7\">" + data.title + "</span>: " +
              "<strong>" + Highcharts.numberFormat(this.y, 0, ',') + "</strong>";
            }
            else {
              return Highcharts.dateFormat(data.tooltip.dateFormat, this.x) + "<br>" +
              "<span style=\"fill:#4572A7\">" + data.title + "</span>: " +
              "<strong>" + Highcharts.numberFormat(this.y, 0, ',') + "</strong>";
            }
          }
          else {
            return Highcharts.dateFormat(data.tooltip.dateFormat, chart.x) + "<br>" +
            "<span style=\"fill:#4572A7\">" + this.series.name + "</span>: " +
            "<strong>" + Highcharts.numberFormat(chart.y, 0, ',') + "</strong>";
          }
        };
      }

      if (data.tooltip.commit_volume_chart) {
        data.tooltip.formatter = Charts.commit_volume_formatter;
      }

      if (data.plotOptions && data.plotOptions.pie) {
        data.tooltip.formatter = function() {
          return "<strong>" + this.point.name + "</strong>: " +
            Highcharts.numberFormat(this.y, 0, ',') +
            " (" + Math.floor(this.percentage) + "%" + ")";
        };

        if (!data.plotOptions.pie.dataLabels) {
          data.plotOptions.pie.dataLabels = {};
        }
        data.plotOptions.pie.dataLabels.formatter = function() {
          return "<strong>" + this.point.name + "</strong>: " + Math.floor(this.percentage) + "%";
        };
      }

      if(data.tooltip.customFormat) {
        data.tooltip.formatter = function() {
          var pname = data.series.name || this.series.name;
          return '<b>' + this.x.commit_month + '</b><br/>' +
            pname + ': ' + this.y + '<br/>';
        };
      }
    }

    var chart = data.highstock ? new Highcharts.StockChart(data) : new Highcharts.Chart(data);
    Charts.charts.push({
      chart: chart,
      data: data,
      parent: this,
      options: options,
      redo: function() {
        Charts.renderChart(chart, data, "", null);
      }
    });
  },
  charts: [],
  init: function() {
    Highcharts.setOptions({
      lang: {
        thousandsSep: ','
      }
    })

    $('.chart').each(function(){
      var $chart = $(this);
      var options = $chart.data();

      if(!$chart.data("alreadyLoaded")) {
        var top = ($chart.height()/2) - 8; // offset the position by 1/2 the height of the spinner gif
        $chart.html("<div class='busy' style='position: relative; top: "+top+"px;'>&nbsp;</div>");
        $.ajax((function(chart){
          var $chart = $(chart);
          return {
            url: $chart.attr('datasrc'),
            context: $chart,
            dataType: 'json',

            success: function(data, textStatus) {
              if(options.pname) data.series.name = options.pname;
              setTimeout(function(){
                Charts.renderChart(chart, data, textStatus, options);
              }, 100);
            }
          };
        })(this));
      }
    });

    for( var i = 0; i < $('.chart-with-data').length; i += 7 ) {
      temp_div = $('.chart-with-data').slice(i, i + 7);
      Charts.process_chunk(temp_div, i);
    }

  },
  commit_volume_formatter: function() {
    return '<strong>' + this.series.name + '</strong><br/>' + this.y + ' Commits (' + Math.floor(this.percentage) + '%)';
  }
}
