class Edit
  BUTTON_TYPES = { org: 'organization_id', account: 'account_id', project: 'project_id' }

  @humanEdits: ->
    if $(this).is(':checked')
      humanParam = 'human=true'
      humanParam = "?#{humanParam}" unless location.search.match('?')
      humanParam = "&#{humanParam}" if location.search.match(/\?\w+/)
      Edit.setupHumanParam(location.search.replace('&&', '&'), humanParam)
    else
      noHumanParam = location.search.replace('human=true', '')
      Edit.setupHumanParam(noHumanParam, '')

  @setupHumanParam: (locationVal, value) ->
    url = "#{location.protocol}//#{location.host}#{location.pathname}"
    strippedUrl = ''
    if location.search.match('page=')
      strippedUrl =  url + locationVal.replace(/page=\d+/.exec(locationVal)[0], '') + value
    else
      strippedUrl = url + locationVal + value

    if strippedUrl.indexOf('?&') == (strippedUrl.length - 2)
      strippedUrl = strippedUrl.replace('?&', '')
    window.location = strippedUrl

  constructor: ($editButton) ->
    @editButton = $editButton
    @undoOrRedoFlag = $editButton.hasClass('undo')
    @parentId = $editButton.closest('tr').attr('parent_id')
    @objectId = $editButton.closest('tr').attr('id').slice(5)

    @editButton.attr 'href', '#'
    @editButton.click =>
      @setupUndoOrRedo()
      false

  buttonType: ->
    if location.pathname.match('/orgs/')
      BUTTON_TYPES['org']
    else if location.pathname.match('/p/')
      BUTTON_TYPES['project']
    else if location.pathname.match('/accounts/')
      BUTTON_TYPES['account']

  setupUndoOrRedo: ->
    $(@editButton).unbind('click').html('Working...')
    $.ajax
      object_id: @objectId
      type: 'POST'
      url: "/edits/#{@objectId}?ajax=1&#{@buttonType()}=#{@parentId}"
      data: {_method: 'put', undo: @undoOrRedoFlag }
      success: (data, textStatus) =>
        $("#edit_#{@objectId}").replaceWith(data)
        new Edit($("#edit_#{@objectId}").find('.undo, .redo'))
      error: (xml_http_request, textStatus, errorThrown) ->
        alert("Error: #{errorThrown}")

$(document).on 'page:change', ->
  $('.edit').find('.undo, .redo').each -> new Edit($(this))
  $('label#human_edits :checkbox').click(Edit.humanEdits)
