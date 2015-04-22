App.Commit = init: ->
  $('#commit-details').one 'click', (e) ->
    e.preventDefault()
    commitId = $(this).attr('commit_id')
    projectId = $(this).attr('project_id')
    $('#icon_play_circle_' + commitId).remove()
    $('#spinner_' + commitId).removeClass('hidden')
    $(this).remove()
    $.ajax
      url: '/p/' + projectId + '/commits/' + commitId + '/statistics'
      success: (html) ->
        $response = $('td.commit_' + commitId)
        $response.removeAttr 'colspan'
        $response.addClass 'hidden'
        $response.after html
$(document).on 'page:change', ->
  App.Commit.init()
