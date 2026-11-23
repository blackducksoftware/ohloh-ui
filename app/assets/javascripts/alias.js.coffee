App.Alias =
  init: ->
    $('#alias-new-page #commit_name_id').change(App.Alias.update_preferred_names).change()
  before: ->
    $('#alias-new-page #submit_button').hide()
    $('#alias-new-page .spinner').show()
  after: ->
    $('#alias-new-page #submit_button').show()
    $('#alias-new-page .spinner').hide()
    $select = $('#alias-new-page select#preferred_name_id')
    $select.chosen('destroy') if $select.data('chosen')
    $select.chosen()
  update_preferred_names: ->
    App.Alias.before()
    commitNameId = $('#alias-new-page #commit_name_id').val()
    $.ajax
      url: $(this).attr('url') + '?commit_name_id=' + commitNameId
      success: (html) ->
        $('#alias-new-page #preferred_name').html html
        App.Alias.after()

$(document).on 'page:change', ->
  App.Alias.init()
