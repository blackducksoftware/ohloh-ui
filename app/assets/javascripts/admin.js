var AdminDashboard = {
  init: function() {
    $("#one_year, #six_months, #three_months_monthly, #six_months_monthly, #one_year_monthly").hide();
    $('input[name="options"]').change( function() {
      AdminDashboard.update_chart($(this).val());
    })
    $('input[name="radio"]').change( function() {
      AdminDashboard.update_chart($(this).val());
    })
  },
  update_chart: function(months) {
    if(months == '3' && $('input[name="radio"]').filter(':checked').val() == 'weekly') {
      $("#three_months").show();
      $("#one_year, #six_months, #three_months_monthly, #six_months_monthly, #one_year_monthly").hide();
    }
    else if(months == '6' && $('input[name="radio"]').filter(':checked').val() == 'weekly'){
      $("#six_months").show();
      $("#one_year, #three_months, #three_months_monthly, #six_months_monthly, #one_year_monthly").hide();
    }
    else if(months == '12' && $('input[name="radio"]').filter(':checked').val() == 'weekly') {
      $("#one_year").show();
      $("#six_months, #three_months, #three_months_monthly, #six_months_monthly, #one_year_monthly").hide();
    }
    else if(months == 'monthly' && $('input[name="options"]').filter(':checked').val() == '3') {
      $("#three_months_monthly").show();
      $("#six_months, #three_months, #one_year, #six_months_monthly, #one_year_monthly").hide();
    }
    else if(months == 'weekly' && $('input[name="options"]').filter(':checked').val() == '3') {
      $("#three_months").show();
      $("#six_months, #three_months_monthly, #one_year, #six_months_monthly, #one_year_monthly").hide();
    }
    else if(months == 'weekly' && $('input[name="options"]').filter(':checked').val() == '6') {
      $("#six_months").show();
      $("#three_months, #three_months_monthly, #one_year, #six_months_monthly, #one_year_monthly").hide();
    }
    else if(months == '3' && $('input[name="radio"]').filter(':checked').val() == 'monthly') {
      $("#three_months_monthly").show();
      $("#three_months, #six_months, #one_year, #six_months_monthly, #one_year_monthly").hide();
    }
    else if(months == '6' && $('input[name="radio"]').filter(':checked').val() == 'monthly') {
      $("#six_months_monthly").show();
      $("#three_months, #six_months, #one_year, #three_months_monthly, #one_year_monthly").hide();
    }
    else if(months == 'monthly' && $('input[name="options"]').filter(':checked').val() == '6') {
      $("#six_months_monthly").show();
      $("#three_months, #six_months, #one_year, #three_months_monthly, #one_year_monthly").hide();
    }
    else if(months == 'monthly' && $('input[name="options"]').filter(':checked').val() == '12') {
      $("#one_year_monthly").show();
      $("#three_months, #six_months, #one_year, #three_months_monthly, #six_months_monthly").hide();
    }
    else if(months == '12' && $('input[name="radio"]').filter(':checked').val() == 'monthly') {
      $("#one_year_monthly").show();
      $("#three_months, #six_months, #one_year, #three_months_monthly, #six_months_monthly").hide();
    }
    else if(months == 'weekly' && $('input[name="options"]').filter(':checked').val() == '12') {
      $("#one_year").show();
      $("#three_months, #six_months, #one_year_monthly, #three_months_monthly, #six_months_monthly").hide();
    }

  }
}
setTimeout("AdminDashboard.init()", 900);