var Expander = {
  init: function() {
    $('#page').on('click', '.expander span[x-wrapper] a.ctrl', function() {
      parent = $(this).parents('span[x-wrapper]:first');
      parent.hide();
      parent.siblings('span[x-wrapper]').show();
    });
  }
}
