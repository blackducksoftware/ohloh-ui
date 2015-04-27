CompareProjects = {
  init:function() {
    $('.projects_compare input.proj').autocomplete({ source: '/autocompletes/project', select: function(e, ui) {
      $(this).val(ui.item.value);
      if ($("#auto_submit").val() != "false")
        $(this).parents('form:first').submit();
    }});
  },
}
