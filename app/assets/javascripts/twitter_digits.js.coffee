class App.TwitterDigits
  # The oauth token expires in 3600 seconds. We are giving our server atleast 5 minutes to use the token.
  OAUTH_EXPIRY_INTERVAL = 3300

  constructor: ->
    initializeDigits()

  authenticate: ($form) ->
    $('#digits-sign-up').click ->
      if oauthTimestampAbsentOrExpired($form)
        requireDigitsLogin($form)
      else
        $form.submit()

  initializeDigits = ->
    Digits.init
      consumerKey: $("meta[name='digits-consumer-key']").attr('content')

  requireDigitsLogin = ($form) ->
    Digits.logIn()
      .done (loginResponse) ->
        oAuthHeaders = loginResponse.oauth_echo_headers
        $form = $('.digits-verification')
        authCredentials = oAuthHeaders['X-Verify-Credentials-Authorization']
        $form.find('#account_digits_credentials').val authCredentials
        $form.find('#account_digits_service_provider_url').val oAuthHeaders['X-Auth-Service-Provider']
        $form.find('#account_digits_oauth_timestamp').val authCredentials.match(/oauth_timestamp="(\d+)"/)[1]
        $form.submit()

  oauthTimestampAbsentOrExpired = ($form) ->
    timestamp = $form.find('#account_digits_oauth_timestamp').val()
    return true if _(timestamp).isEmpty()
    Number(timestamp) + OAUTH_EXPIRY_INTERVAL < currentTimestamp()

  currentTimestamp = ->
    currentDate = new Date()
    currentDate.getTime() / 1000
