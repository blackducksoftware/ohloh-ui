$(document).on 'page:change', ->
  digits = new App.TwitterDigits
  digits.authenticate($('.digits-verification'))
