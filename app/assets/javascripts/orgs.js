var GaugeProgress = {
  init: function(){
    var scope = this;
    var page_ids = ['explore_orgs_page'];
    $.each(page_ids ,function(index,value){
      if ( $('#'+value).length > 0 ) {
        $('[data-gauge]').each(function( index ){
          var elem = $(this)
          var data = elem.data('gauge')
          elem.highcharts( scope.config(data) );
        })
      };
      if (value === 'explore_orgs_page' && $('#'+value).length > 0){
        scope.orgs_progress_bar()
      }
    })
  },

  config: function(data){
    return {
      chart: {
        type: 'solidgauge',
      },
      title: null,
      pane: {
        center: ['50%', '100%'],
        size: '200%',
        startAngle: -90,
        endAngle: 90,
        background: {
          backgroundColor: '#FFF',
          innerRadius: '100%',
          outerRadius: '45%',
          shape: 'arc'
        }
      },
      tooltip: {
        enabled: false
      },
      yAxis: {
        min: 0,
        max: $('[data-gauge-max]').first().data()['gaugeMax'],
        stops: [[0.1, '#2ecc71'], [0.5, '#7b559b'], [0.9, '#482268']],
        minorTickInterval: null,
        tickPixelInterval: 400,
        tickWidth: 0,
        gridLineWidth: 0,
          labels: {
            enabled: false
          },
        title: {
            enabled: false
        }
      },
      credits: {
        enabled: false
      },
      plotOptions: {
        solidgauge: {
          innerRadius: '45%',
          dataLabels: {
            y: 10,
            borderWidth: 0,
            useHTML: true
          }
        }
      },
      series: [{data: [data], dataLabels: { format: '<p style="text-align:center;">{y}</p>'} }],
      exporting: {
        enabled: false
      }
    }
  },

  orgs_progress_bar: function(){
    $('.progress #progress-bar').each(function(index){
      var elem = $(this);
      var aria_max = elem.attr('aria-valuemax');
      var aria_now = elem.attr('aria-valuenow');
      var aria_per_pixel = (aria_now * 222 / aria_max);
      elem.width( aria_per_pixel );
      elem.text(aria_now);
    });
  }
};

var OrgsFilter = {
  init: function(){
    $('#explore_orgs_page .chzn-select').chosen().change(function(){
      $('.busy#commit_volume_loader').toggleClass('hidden')
      $('#orgs_by_30_days_volume table').toggleClass('hidden')
      $.ajax({
        url: '/explore/orgs_by_thirty_day_commit_volume?format=js&filter='+ $(this).val(),
        type: "GET",
        success: function(){
          $('#orgs_by_30_days_volume table').toggleClass('hidden')
          $('.busy#commit_volume_loader').toggleClass('hidden')
        }
      })
    })
  }
}

var OrgClaimProject = {
  init: function(){
    $('.org-claim-project').click(function(){
      var url = $(this).data('url');
      $(this).html(StackShow.busy_div);
      var link_id = $(this).attr('id');

      $.ajax({
        type: "GET",
        url: url,
        success: function(data){
          $('#'+link_id).replaceWith(data);
        }
      });
      return false;
    });
  }
}
$(document).ready(function() {
  OrgClaimProject.init()
});
