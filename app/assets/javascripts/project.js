var ProjectDashboard = {
  init: function() {
    $('input[name="project_filter"]').attr("autocomplete", "off");
    $('.project').hide().filter('#three_months_project').show();
    //This is used to change the chart based on button 3 months, 6months and 1 year.
    $('input[name="project_options"]').change( function() {
      ProjectDashboard.update_chart($('input[name="project_filter"]').filter(':checked').val());
    })
    //This is used to filter the chart based on weekly and monthly.
    $('input[name="project_filter"]').change( function() {
      ProjectDashboard.update_chart($(this).val());
    })
  },
  update_chart: function(filter) {
    if(filter == 'monthly') {
      var contClass = $('input[name="project_options"]').filter(':checked').data('div');
      $('.project').hide().filter('#' + contClass + '_monthly_project').show();
    }
    else if(filter == 'weekly') {
      var contClass = $('input[name="project_options"]').filter(':checked').data('div');
      $('.project').hide().filter('#' + contClass + '_project').show();
    }
  }
}
setTimeout("ProjectDashboard.init()", 900);