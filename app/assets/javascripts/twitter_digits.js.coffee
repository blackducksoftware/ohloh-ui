class App.TwitterDigits
  authenticate: ($form) ->
    $('#digits-sign-up').click ->
      requireDigitsLogin($form)

  requireDigitsLogin = ($form) ->
    Digits.logIn()
      .done (loginResponse) ->
        oAuthHeaders = loginResponse.oauth_echo_headers
        $form = $('.digits-verification')
        authCredentials = oAuthHeaders['X-Verify-Credentials-Authorization']
        $form.find('#credentials').val authCredentials
        $form.find('#service_provider_url').val oAuthHeaders['X-Auth-Service-Provider']
        $form.submit()

$(document).on 'page:change', ->
  digits = new App.TwitterDigits()
  digits.authenticate($('.digits-verification'))

  Digits.init
    consumerKey: $("meta[name='digits-consumer-key']").attr('content')
