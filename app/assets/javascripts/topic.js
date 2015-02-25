MoveTopicLink = {
  init: function() {
    $("#move_link").click(MoveTopicLink.moveit);
  },

  moveit: function() {
    var u = $(this).attr('href') + "?height=110&width=300";
    tb_show('Move Topic', u, false);
    return false;
  }
}