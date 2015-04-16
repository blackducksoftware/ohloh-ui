App.Commit = init: ->
  $(document).on 'click', 'a[data-toggle="commit-details"]', (e) ->
    e.preventDefault()
    commit_id = $(this).attr('commit_id')
    project_id = $(this).attr('project_id')
    $(this).next().show()
    #show spinner
    $(this).prev().remove()
    #Remove the icon-play-circle (bootstrap-icon)
    $(this).remove()
    #Remove the link to avoid multiple click(s)
    $.ajax
      url: '/p/' + project_id + '/commits/' + commit_id + '/statistics'
      success: (data, textStatus) ->
        $response = $('td.commit_' + commit_id)
        $response.removeAttr 'colspan'
        $response.addClass 'center'
        res = data.split('||')
        $response.html res[0]
        $response.after '<td class=\'center\'>' + res[1] + '</td><td class=\'center\'>' + res[2] + '</td><td class=\'center\' title=\'' + res[4] + '\'>' + res[3] + '</td>'
$(document).on 'page:change', ->
  App.Commit.init()
