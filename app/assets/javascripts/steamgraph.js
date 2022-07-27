var check_ie_version = (function(){
  var undef,
      v = 3,
      div = document.createElement('div'),
      all = div.getElementsByTagName('i');
  while (
      div.innerHTML = '<!--[if gt IE ' + (++v) + ']><i></i><![endif]-->',
      all[0]
  );
  return v > 4 ? v : undef;
}());

Streamgraph = {
  init: function(){
     if (check_ie_version < 9) {  //Check if its less than IE9
        return Streamgraph.render_IE_not_supported();
     }
     $('.stream_graph').each(function(){
      var $chart = $(this);
      var options = $chart.data();
      if(!$chart.data("alreadyLoaded")) {
        var top = ($chart.height()/2) - 8; // offset the position by 1/2 the height of the spinner gif
        $chart.html("<div class='busy' style='position: relative; top: "+top+"px;'>&nbsp;</div>");

        $.ajax((function(chart){
          var $chart = $(chart);
          var scope = $chart.attr('datascope');
          return {
            url: $chart.attr('datasrc'),
            context: $chart,
            dataType: 'json',
            success: function(data, textStatus) {
              object_array = data.object_array;
              date_array = data.date_array;
              Streamgraph.renderChart();
              $(".busy").remove();
              $('#streamgraph_category').change(function(){
                val = $("#streamgraph_category").val();
                d3.select("svg").remove();
                $("#ohloh_streamgraph").empty();
                $('#ohloh_streamgraph').siblings('p').remove(); //remove no commits message
                var object_array = data.object_array;
                Streamgraph.renderChart();
              });

            }
          };
        })(this));
      }
    });
    },
    renderChart: function(){
      var scope = $("#ohloh_streamgraph").attr('datascope');
      var selected_category = $("#streamgraph_category").val();
      var data = $('#streamgraph_category').data('streamgraph_category');
      var arrays, colors, legends;
      if(selected_category == "#" || selected_category == undefined){
        arrays = object_array.map(function(m){return m.table.commits});
        colors = object_array.map(function(m){return m.table.color_code});
        legends = object_array.map(function(m){return m.table.nice_name});
      } else {
        arrays = object_array.filter(function(m){ return m.table.category == selected_category}).map(function(m){return m.table.commits});
        colors = object_array.filter(function(m){ return(m.table.category == selected_category)}).map(function(m){return m.table.color_code});
        legends = object_array.filter(function(m){ return (m.table.category == selected_category)}).map(function(m){return m.table.nice_name});
      }
      if (arrays.length == 0) {
        Charts.renderNoCommitsMessage("#ohloh_streamgraph", 'margin-left:40px;');
        return;
      }
      $('#ohloh_streamgraph').show();
      if (scope == "regular"){ Streamgraph.populate_legends(legends, colors); }
      var parsed_dates = date_array.map(function(dateString, index){return dateFromString(dateString);});
      var stack = d3.layout.stack().offset('silhouette');
      var layers = stack(arrays.map(function(data){
        return data.map(function(datum, index){
          return {x: parsed_dates[index], y: datum};
        });
      }));
      // OTWO-2651 Since Date.parse doesn't work in Safari(Win) we have to do it manually
      function dateFromString(str) {
        var a = $.map(str.split(/[^0-9]/), function(s) { return parseInt(s, 10) });
        return new Date(a[0], a[1]-1 || 0, a[2] || 1, a[3] || 0, a[4] || 0, a[5] || 0, a[6] || 0);
      }

      if (scope == "full")
        {var width = 900; var height = 300; var transform_new = 0;}
      else
        if (window.innerWidth >= 320 && window.innerWidth <= 480)
          {var width = 150; var height = 300; var transform_new = 0;}
        else if (window.innerWidth >= 768 && window.innerWidth <= 1024)
          {var width = 515; var height = 300; var transform_new = 0;}
        else
          {var width = 715; var height = 300; var transform_new = 0;}

      var margin = {top: 0, right: 0, bottom: 0, left: 0};
      var width = width - margin.left - margin.right
      var height = height - margin.top - margin.bottom;


      var y = d3.scale.linear()
          .range([height, 0]);

      yAxis = d3.svg.axis().scale(y).ticks(4).orient("right");

      var x = d3.time.scale().range([0, width]);

      var xAxis = d3.svg.axis()
          .scale(x)
          .tickSize(-height)
          .tickSubdivide(true)
          .orient("bottom")
          .tickSize(1)
          .tickFormat(d3.time.format('%b %Y'));

      var area = d3.svg.area()
          .interpolate("basis")
          .x(function(d) { return x(d.x); })
          .y0(function(d) { return y(d.y0); })
          .y1(function(d) { return y(d.y0 + d.y); });

      var svg = d3.select("#ohloh_streamgraph").append("svg")
          .attr("id", "ohloh_stream")
          .attr("width", width)
          .attr("height", height)
          .attr('class', 'background-watermark');

      var focus = svg.append("g")
          .attr('class', 'graphics')
          .attr("transform", "translate(0,"+transform_new+")");

        x.domain([parsed_dates[0], parsed_dates[date_array.length - 1]]);

        Array.max = function( array ){
          return Math.max.apply( Math, array );
        };

        var total = 0;
        var max_commits_by_month = [];
        // Initialize max_commits_by_month to 0 values
        for (var i = 0; i < arrays[0].length; i++) {
          max_commits_by_month[i] = 0;
        };
        for (var i = 0; i < arrays.length; i++) {
          for (var month = 0; month < arrays[i].length; month++) {
            max_commits_by_month[month] += arrays[i][month];
          }
        };
        total = Array.max(max_commits_by_month);
        y.domain([0, total]);
        //Show the X-Axis only for full width
        if (scope == "full"){
          g = svg.append("g")
              .attr("class", "x_axis")
              .attr("transform", "translate(5," + (height-20) + ")");
          g.call(xAxis);
        }

        layers.forEach(function(data, index){

          var gg = focus.append('g')
            .attr('class', 'plot ' + legends[index] + '-path')
            .attr('transform', "translate(0, " + 0 + ")");

          gg.append('title')
            .attr("dy", ".3em")
            .attr('class', 'tip')
            .text(function(d){return legends[index]});

          gg.append("path")
            .datum(data)
            .attr('d', area)
            .attr('stroke-width', 5)
            .style("fill", "#" + colors[index])
            .on('mouseover', function(d, i){
                var elem = d3.select(this);
                elem.classed('highlight', true);
            }).on('mouseout', function(d, i){
                var elem = d3.select(this);
                elem.classed('highlight', false);
            });;
        });
    },
  populate_legends: function(legends, colors){
    legend_height = Math.min(legends.length * 18 + 5, 300);
    $('#ohloh_streamgraph').after('<div id="streamgraph_legend" style="height:' + legend_height + 'px;"></div>');
    legends.map( function(l, i) {
      div = "<div class='streamgraph_legend_color' style='background-color: #"+colors[i]+"'></div><p>"+legends[i]+"</p>";
      $("#streamgraph_legend").append(div);
    });
  },

  render_IE_not_supported: function(){
    $("#ohloh_streamgraph").addClass("streamgraph_IE_not_supported");
    $("#streamgraph_category").hide();
    msg = "This graph cannot be displayed in IE below version 9.  Please consider upgrading your browser."
    $("#ohloh_streamgraph").append("<div class='stream_error'>"+msg+"</div>");
  }
}

$(document).on('page:change', function() {
  Streamgraph.init();
})
