App.NeedsLogin =
  init: ->
    $('.needs_login').click (e) ->
      e.preventDefault()
      redirectTo = @href or window.location.href
      inviteArg = (if $(this).hasClass('invite') then "&invite=#{$(this).attr('id').slice('invite_'.length)}" else '')
      actionArg = (if $(this).hasClass('action') then "&action=#{$(this).attr('id').slice('action_'.length)}" else '')
      url = '/sessions/new?return_to=' + encodeURIComponent(redirectTo) + inviteArg + actionArg
      if not window['IS_DEV'] and window.location.protocol is 'http:'
        window.location = url
      else
        tb_show 'Login Required', url + '&height=300&width=370', false

$ ->
  App.NeedsLogin.init()
