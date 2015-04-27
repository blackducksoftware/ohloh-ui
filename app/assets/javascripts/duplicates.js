NewDuplicate = {
  init:function() {
    $('input#duplicate_autocomplete').autocomplete({
      source: '/autocompletes/project',
      select: function(event, ui) {
        $("#duplicate_good_project_id").val(ui.item.id);
        var project_url = $('a#good_project_url').attr('base') + '/' + ui.item.id;
        $('a#good_project_url').attr('href', project_url).text(project_url);
        $("#good_project_url_label").removeClass('hidden');
      }
    });
  }
}
