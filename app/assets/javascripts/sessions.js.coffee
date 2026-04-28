$(document).on 'page:change', ->
  $('#sign-in-email').click ->
    $('#sign-in-options').remove()
    $('#sign-in-fields').show()
