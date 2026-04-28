$(document).on 'page:change', ->
  $('#sign-in-email').click ->
    $('#sign-in-options').remove()
    $('#sign-in-fields').show()

  $(document).on 'click', '[data-dismiss="auth-alert"]', (e) ->
    e.preventDefault()
    $(this).closest('.auth-alert').fadeOut 200, -> $(this).remove()
