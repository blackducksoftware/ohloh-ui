class App.NeedsVerification
  constructor: ($element)->
    $element.click (event) ->
      url = '/accounts/me/verifications/new?'  # new_account_verification_path
      thickboxHelper = new App.ThickboxHelper()
      tb_show 'Mobile Verification Required', thickboxHelper.addParams(url), false

$(document).on 'page:change', ->
  new App.NeedsVerification($('.needs_verification'))
