App.NeedsLogin =
  init: ->
    $('.needs_login').click (e) ->
      e.preventDefault()
      redirectTo = @href or window.location.href
      inviteArg = (if $(this).hasClass('invite') then "&invite=#{$(this).attr('id').slice('invite_'.length)}" else '')
      actionArg = (if $(this).hasClass('action') then "&action=#{$(this).attr('id').slice('action_'.length)}" else '')
      url = '/sessions/new?return_to=' + encodeURIComponent(redirectTo) + inviteArg + actionArg
      thickboxHelper = new App.ThickboxHelper()
      tb_show 'Login Required', thickboxHelper.addParams(url), false

$(document).on 'page:change', ->
  App.NeedsLogin.init()
