App.Commit = init: ->
  $(document).on 'click', 'a[data-toggle="commit-details"]', (e) ->
    e.preventDefault()
    commit_id = $(this).attr('commit_id')
    project_id = $(this).attr('project_id')
    $('#icon_play_circle_' + commit_id).remove()
    $('#spinner_' + commit_id).removeClass('hidden')
    $(this).remove()
    $.ajax
      url: '/p/' + project_id + '/commits/' + commit_id + '/statistics'
      success: (html) ->
        $response = $('td.commit_' + commit_id)
        $response.removeAttr 'colspan'
        $response.addClass 'hidden'
        $response.after html
$(document).on 'page:change', ->
  App.Commit.init()
