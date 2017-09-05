var uiConfig = {
  // Url to redirect to after a successful sign-in.
  'signInSuccessUrl': '/',
  'callbacks': {
    'signInSuccess': function(user, credential, redirectUrl) {
      $form = $('.digits-verification');
      authCredentials = user.ze
      $form.find('#credentials').val(authCredentials);
      $form.submit();
      // The widget has been opened in a popup, so close the window
      // and return false to not redirect the opener.
      window.close();
      return false;
      if (window.opener) {
      } else {
        // The widget has been used in redirect mode, so we redirect to the signInSuccessUrl.
        return true;
      }
    }
  },
  'signInFlow': 'popup',
  'signInOptions': [
    {
      provider: firebase.auth.PhoneAuthProvider.PROVIDER_ID,
      recaptchaParameters: {
        size: 'invisible'
      }
    }
  ],
  // Terms of service url.
  'tosUrl': 'https://www.google.com'
};
function getWidgetUrl() {
  return '/widget#recaptcha=invisible';
}
// Initialize the FirebaseUI Widget using Firebase.
var ui = new firebaseui.auth.AuthUI(firebase.auth());
var signInWithPopup = function() {
  ui.start('#firebaseui-auth-container', uiConfig);
};
$(document).on('page:change', function() {
  document.getElementById('digits-sign-up').addEventListener('click', signInWithPopup);
});
