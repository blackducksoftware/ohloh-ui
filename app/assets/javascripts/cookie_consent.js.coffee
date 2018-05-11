CookieConsent =
  init: () ->
    cookiesAllowed = Cookies.get('cookie_consented')
    $('.cc_accept').on 'click', (e) ->
      CookieConsent.set() unless cookiesAllowed == 'yes'
  set: () ->
    Cookies.set 'cookie_consented', 'yes', expires: 365
    cookiesAllowed = 'yes'
    $('#cookies-bar').hide()
    return

$(document).on 'page:change', ->
  CookieConsent.init()