class App.NeedsVerification
  constructor: ($element)->
    $element.click (event) ->
      url = '/authentications/new?'      # new_authentication_path
      thickboxHelper = new App.ThickboxHelper()
      tb_show 'Verification Required', thickboxHelper.addParams(url), false

$(document).on 'page:change', ->
  new App.NeedsVerification($('.needs_verification'))
