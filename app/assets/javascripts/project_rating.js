var ProjectRating = {
  init: function() {
    this.hook_ratings();
    this.clear_ratings();
  },

  hook_ratings: function() {
    $(".jrating").each(
      function(i) {
        var project_id = $(this).attr('id');
        var star_style = $(this).attr('star_style') || 'small';
        if ($(this).children().length == 0) {
          var show = $(this).attr('data-show');
          $(this).rater("/p/" + project_id + "/rate?show="+show, {
            style: star_style,
            instantGratification: true,
            curvalue: $(this).attr('score'),
            read_only: $(this).attr('read_only') || false,
            a_klass: $(this).hasClass('needs_login') ? "needs_login" : "",
            success: function(data) {
              $("#rating_spinner").hide();
              ProjectRating.init();
            }
          });
        }
      }
    )
  },

  clear_ratings: function(){
    $("#clear").click( function(){
      $.ajax({
        url: $("#clear a").attr("data-url"),
          type: "DELETE",
          beforeSend: function() {
              $("#clear").hide();
              $("#rating_spinner").show();
          },
          success: function(data) {
              $("#proj_rating").html(data);
              $("#rating_spinner").hide();
              ProjectRating.init();
          }
      });
      return false;
    });
  }
}

$( document ).ready(function() {
    ProjectRating.init();
});
