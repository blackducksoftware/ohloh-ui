var ProjectDashboard = {
  init: function() {
    $("#one_year_project, #six_months_project, #three_months_monthly_project, #six_months_monthly_project, #one_year_monthly_project").hide();
    $('input[name="options_project"]').change( function() {
      console.log("hiiiiii");
      ProjectDashboard.update_chart($(this).val());
    })
    $('input[name="radio_project"]').change( function() {
      ProjectDashboard.update_chart($(this).val());
    })
  },
  update_chart: function(months) {
    if(months == '3' && $('input[name="radio_project"]').filter(':checked').val() == 'weekly') {
      $("#three_months_project").show();
      $("#one_year_project, #six_months_project, #three_months_monthly_project, #six_months_monthly_project, #one_year_monthly_project").hide();
    }
    else if(months == '6' && $('input[name="radio_project"]').filter(':checked').val() == 'weekly'){
      $("#six_months_project").show();
      $("#one_year_project, #three_months_project, #three_months_monthly_project, #six_months_monthly_project, #one_year_monthly_project").hide();
    }
    else if(months == '12' && $('input[name="radio_project"]').filter(':checked').val() == 'weekly') {
      $("#one_year_project").show();
      $("#six_months_project, #three_months_project, #three_months_monthly_project, #six_months_monthly_project, #one_year_monthly_project").hide();
    }
    else if(months == 'monthly' && $('input[name="options_project"]').filter(':checked').val() == '3') {
      $("#three_months_monthly_project").show();
      $("#six_months_project, #three_months_project, #one_year_project, #six_months_monthly_project, #one_year_monthly_project").hide();
    }
    else if(months == 'weekly' && $('input[name="options_project"]').filter(':checked').val() == '3') {
      $("#three_months_project").show();
      $("#six_months_project, #three_months_monthly_project, #one_year_project, #six_months_monthly_project, #one_year_monthly_project").hide();
    }
    else if(months == 'weekly' && $('input[name="options_project"]').filter(':checked').val() == '6') {
      $("#six_months_project").show();
      $("#three_months_project, #three_months_monthly_project, #one_year_project, #six_months_monthly_project, #one_year_monthly_project").hide();
    }
    else if(months == '3' && $('input[name="radio_project"]').filter(':checked').val() == 'monthly') {
      $("#three_months_monthly_project").show();
      $("#three_months_project, #six_months_project, #one_year_project, #six_months_monthly_project, #one_year_monthly_project").hide();
    }
    else if(months == '6' && $('input[name="radio_project"]').filter(':checked').val() == 'monthly') {
      $("#six_months_monthly_project").show();
      $("#three_months_project, #six_months_project, #one_year_project, #three_months_monthly_project, #one_year_monthly_project").hide();
    }
    else if(months == 'monthly' && $('input[name="options_project"]').filter(':checked').val() == '6') {
      $("#six_months_monthly_project").show();
      $("#three_months_project, #six_months_project, #one_year_project, #three_months_monthly_project, #one_year_monthly_project").hide();
    }
    else if(months == 'monthly' && $('input[name="options_project"]').filter(':checked').val() == '12') {
      $("#one_year_monthly_project").show();
      $("#three_months_project, #six_months_project, #one_year_project, #three_months_monthly_project, #six_months_monthly_project").hide();
    }
    else if(months == '12' && $('input[name="radio_project"]').filter(':checked').val() == 'monthly') {
      $("#one_year_monthly_project").show();
      $("#three_months_project, #six_months_project, #one_year_project, #three_months_monthly_project, #six_months_monthly_project").hide();
    }
    else if(months == 'weekly' && $('input[name="options_project"]').filter(':checked').val() == '12') {
      $("#one_year_project").show();
      $("#three_months_project, #six_months_project, #one_year_monthly_project, #three_months_monthly_project, #six_months_monthly_project").hide();
    }

  }
}
setTimeout("ProjectDashboard.init()", 900);