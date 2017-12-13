App.PasswordReset =
  init: ->
    $('.password-reset form').submit ->
      $(this).find('input[type="submit"]').prop 'disabled', 'disabled'
    
$(document).ready ->
  App.PasswordReset.init()
