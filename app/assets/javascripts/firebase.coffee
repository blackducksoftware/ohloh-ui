uiConfig = ->
  'signInSuccessUrl': '/'
  'callbacks':
    'signInSuccess': (user) ->
      user.getIdToken().then (idToken) ->
        $form = $('.digits-verification')
        $form.find('#credentials').val idToken
        $form.submit()
      false
  'signInFlow': 'popup'
  'signInOptions': [ {
    provider: firebase.auth.PhoneAuthProvider.PROVIDER_ID
    recaptchaParameters: size: 'invisible'
  } ]
  'tosUrl': 'https://blog.openhub.net/terms/'

initializeFirebase = ->
  firebase.initializeApp(
    apiKey: $('[name=firebase-consumer-key]').attr('content')
    authDomain: $('[name=firebase-app-url]').attr('content')
    projectId: $('[name=firebase-app-id]').attr('content')
  )

displayUI = ->
  ui = new firebaseui.auth.AuthUI(firebase.auth())
  ui.start '#firebaseui-auth-container', uiConfig()

$(document).on 'page:change', ->
  $('#digits-sign-up').click ->
    initializeFirebase()
    displayUI()
