App.ProjectShow =
  init: ->
    return if $('#projects_show_page').length == 0
    setTimeout (->
      $('#browse_code_button').removeClass 'hidden'
      $('#browse_code_button').addClass 'animated slideInRight'
      return
    ), 1000

    setTimeout (->
      $('#browse_security_button').removeClass 'hidden'
      $('#browse_security_button').addClass 'animated flip'
      return
    ), 3000

$(document).on 'page:change', ->
  App.ProjectShow.init()
