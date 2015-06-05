SimilarProjects =
  init: ->
    return unless $('#projects_show_page').length

    $('#similar_projects').html('')
    $('#related_spinner').removeClass('hidden')

    projectId = $('#similar_projects').data('projectId')
    $.ajax
      url: "/p/#{ projectId }/similar_by_tags"
      success: (data) ->
        $('#similar_projects').html(data)
      complete: ->
        $('#related_spinner').addClass('hidden')

$(document).on 'page:change', ->
  SimilarProjects.init()
