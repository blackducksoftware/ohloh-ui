class App.NeedsEmailVerification
  constructor: ($element)->
    $element.click (event) ->
      url = '/activation_resends/new?'  # new_account_verification_path
      thickboxHelper = new App.ThickboxHelper()
      tb_show 'Please verify your email address', thickboxHelper.addParams(url), false

$(document).on 'page:change', ->
  new App.NeedsEmailVerification($('.needs_email_verification'))
