$(document).on 'page:change', ->
  PermissionForm.init()
  return

PermissionForm =
  init: ->
    $('#permission_show input[type=radio]').click PermissionForm.enable_submit
    return
  enable_submit: ->
    $('#permission_show input#submit').show()
    return
