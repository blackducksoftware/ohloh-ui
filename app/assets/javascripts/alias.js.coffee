App.Alias =
  init: ->
    $('.alias #commit_name_id').change(App.Alias.update_preferred_names).change()
  before: ->
    $('.alias #submit_button').hide()
    $('.alias .spinner').show()
  after: ->
    $('.alias #submit_button').show()
    $('.alias .spinner').hide()
    $('.alias select#preferred_name_id').chosen()
  update_preferred_names: ->
    App.Alias.before()
    $.ajax
      url: $(this).attr('url') + '?commit_name_id=' + $('#commit_name_id').val()
      success: (html) ->
        $('.alias #preferred_name').html html
        App.Alias.after()

$(document).on 'page:change', ->
  App.Alias.init()
