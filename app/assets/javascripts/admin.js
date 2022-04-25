var AdminDashboard = {
  init: function() {
    $('input[name="radio"]').attr("autocomplete", "off");
    $('.account').hide().filter('#three_months').show();
    $('input[name="options"]').change( function() {
      AdminDashboard.update_chart($('input[name="radio"]').filter(':checked').val());
    })
    $('input[name="radio"]').change( function() {
      AdminDashboard.update_chart($(this).val());
    })
  },
  update_chart: function(filter) {
    if(filter == 'weekly') {
      var contClass = $('input[name="options"]').filter(':checked').data('div');
      $('.account').hide().filter('#' + contClass).show();
    }
    else if(filter == 'monthly'){
      var contClass = $('input[name="options"]').filter(':checked').data('div');
      $('.account').hide().filter('#' + contClass + '_monthly').show();
    }
  }
}
setTimeout("AdminDashboard.init()", 900);