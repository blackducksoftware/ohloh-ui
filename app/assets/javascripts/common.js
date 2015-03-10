var Expander = {
  init: function() {
    $(".expander span a").click( function() {
      $(this).parent().hide();
      $(this).parent().siblings().show();
    });
  }
}
