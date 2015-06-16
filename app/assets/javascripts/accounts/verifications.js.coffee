$(document).on 'page:change', ->
  Digits.init
    consumerKey: $("meta[name='digits-consumer-key']").attr('content')

  $('#digits-sign-up').click ->
    Digits.logIn()
      .done (loginResponse) ->
        oAuthHeaders = loginResponse.oauth_echo_headers
        $form = $('#new_verification')
        $form.find('#verification_credentials').val oAuthHeaders['X-Verify-Credentials-Authorization']
        $form.find('#verification_service_provider_url').val oAuthHeaders['X-Auth-Service-Provider']
        $form.submit()
