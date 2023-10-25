class Edit
  BUTTON_TYPES = { org: 'organization_id', account: 'account_id', project: 'project_id' }

  @humanEdits: ->
    if $(this).is(':checked')
      humanParam = 'human=true'
      humanParam = "?#{humanParam}" unless location.search.match(/\?/)
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

          if $(@editButton).hasClass('project') && @undoOrRedoFlag
            @refreshEnlistment()
        error: (xml_http_request, textStatus, errorThrown) ->
              alert("Error: #{errorThrown}")

   refreshEnlistment: ->
    enlistments = $('.enlistment.undo')
    i = 0
    while i < enlistments.length
      element = enlistments[i]
      @objectId = $(element).closest('tr')[0].id.slice(5)
      $.ajax
       type: 'GET'
       url: "/p/#{@parentId}/edits/refresh/#{@objectId}?ajax=1"
       success: (data, textStatus) ->
        tr = $(data).closest('tr').attr('id')
        $('#' + tr).replaceWith(data)

       error: (xml_http_request, textStatus, errorThrown) ->
        alert 'Error: ' + errorThrown
      i++


$(document).on 'page:change', ->
  $('.edit').find('.undo, .redo').each -> new Edit($(this))
  $('label#human_edits :checkbox').click(Edit.humanEdits)
  $('#enlistment_checkbox').click ->
      url = location.protocol + '//' + location.host + location.pathname
      checked = undefined
      if $(this).is(':checked')
        checked = true
      else
        checked = false
      $.ajax
        type: 'GET'
        url: url
        data: enlistment: checked
        success: (result) ->
          _html = $.parseHTML(result)
          $('#page').html _html
          return
        error: (result, err) ->
          console.log err
          return
      return
