var ProjectDashboard = {
  init: function() {
    $('input[name="radio_project"]').attr("autocomplete", "off");
    $("#one_year_project, #six_months_project, #three_months_monthly_project, #six_months_monthly_project, #one_year_monthly_project").hide();
    $('input[name="options_project"]').change( function() {
      ProjectDashboard.update_chart($(this).val(), $('input[name="radio_project"]').filter(':checked').val());
    })
    $('input[name="radio_project"]').change( function() {
      ProjectDashboard.update_chart($('input[name="options_project"]').filter(':checked').val(), $(this).val());
    })
  },
  update_chart: function(months, filter) {
    if(months == '3' && filter == 'weekly') {
      $("#three_months_project").show();
      $("#one_year_project, #six_months_project, #three_months_monthly_project, #six_months_monthly_project, #one_year_monthly_project").hide();
    }
    else if(months == '6' && filter == 'weekly'){
      $("#six_months_project").show();
      $("#one_year_project, #three_months_project, #three_months_monthly_project, #six_months_monthly_project, #one_year_monthly_project").hide();
    }
    else if(months == '12' && filter == 'weekly') {
      $("#one_year_project").show();
      $("#six_months_project, #three_months_project, #three_months_monthly_project, #six_months_monthly_project, #one_year_monthly_project").hide();
    }
    else if(months == '3' && filter == 'monthly') {
      $("#three_months_monthly_project").show();
      $("#six_months_project, #three_months_project, #one_year_project, #six_months_monthly_project, #one_year_monthly_project").hide();
    }
    else if(months == '6' && filter == 'monthly') {
      $("#six_months_monthly_project").show();
      $("#three_months_project, #six_months_project, #one_year_project, #three_months_monthly_project, #one_year_monthly_project").hide();
    }
    else if(months == '12' && filter == 'monthly') {
      $("#one_year_monthly_project").show();
      $("#three_months_project, #six_months_project, #one_year_project, #three_months_monthly_project, #six_months_monthly_project").hide();
    }
  }
}
setTimeout("ProjectDashboard.init()", 900);