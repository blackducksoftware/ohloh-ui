var AdminDashboard = {
  init: function() {
    $("#six_months").hide();
    $("#one_year").hide();
    $('input[name="options"]').change( function() {
      AdminDashboard.update_chart($(this).val());
    })
  },
  update_chart: function(months) {
    if(months == '3') {
      $("#three_months").show();
      $("#six_months").hide();
      $("#one_year").hide();
    }
    else if(months == '6') {
      $("#six_months").show();
      $("#three_months").hide();
      $("#one_year").hide();
    }
    else if(months == '12') {
      $("#one_year").show();
      $("#six_months").hide();
      $("#three_months").hide();
    }
  }
}
setTimeout("AdminDashboard.init()", 900);