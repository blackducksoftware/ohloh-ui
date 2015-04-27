Explore =
  init: () ->
    return if $('#explore_projects_page').length == 0

    $('#explore_search_form .icon-search').click (e) ->
      e.preventDefault()
      $(this).closest('form').trigger('submit')
      return false

    $("#explore_search_form input[name='q']").keydown (e) ->
      if e.which == 13
        e.preventDefault()
        $(this).siblings('.icon-search').trigger('click')
        return false

    JumpToTag.init()
    CompareProjects.init()

    $('.similar_projects #project').autocomplete
      source: '/autocompletes/project'
      select: (e, ui) ->
        $('#project').val(ui.item.value)
        $('#proj_id').val(ui.item.id)
        $(this).parents('form:first').submit()

    $('.similar_projects .icon-search').click (e) ->
      $(this).parents('form:first').submit()

    $('form[rel=similar_project_jump]').submit (e) ->
      projectId = $("#proj_id").val()
      if $('#project').val() != '' and projectId != ''
        e.preventDefault()
        $('#proj_id').val('')
        window.location.href = "/p/#{projectId}/similar"
      else
        $('span.error').show()
        return false

TagCloud =
  init: () ->
    $.fn.tagcloud.defaults =
      size:
        start: 10
        end: 18
        unit: 'pt'
      color:
        start: '#999'
        end: '#000'
    $('#tagcloud a').tagcloud()

$ ->
  Explore.init()
  TagCloud.init()
