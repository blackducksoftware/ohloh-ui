class App.NeedsEmailVerification
  constructor: ($element)->
    $element.click (event) ->
      url = '/activation_resends/new?'  # new_activation_resend_path
      thickboxHelper = new App.ThickboxHelper()
      tb_show 'Please verify your email address', thickboxHelper.addParams(url), false

$(document).on 'page:change', ->
  new App.NeedsEmailVerification($('.needs_email_verification'))
