App.Explore =
  init: () ->
    return if $('#explore_projects_page').length == 0

    $('#explore_search_form .icon-search').click (e) ->
      e.preventDefault()
      $(this).closest('form').trigger('submit')
      return false

    $("#explore_search_form input[name='query']").keydown (e) ->
      if e.which == 13
        e.preventDefault()
        $(this).siblings('.icon-search').trigger('click')
        return false

    $('.similar_projects .icon-search').click (e) ->
      $(this).parents('form:first').trigger('submit')

    $('form[rel=similar_project_jump]').submit (e) ->
      projectId = $("#project").val()
      if projectId != ''
        e.preventDefault()
        window.location.href = "/p/#{projectId.toLowerCase()}/similar"
      else
        $('span.error').removeClass('hidden')
        false

    $('form[rel=sort_filter] select').change () ->
      if $('#explore_projects_page') && $(this).val() == ''
        $(this).attr('disabled', 'disabled')
      $(this).parents('form').attr('action', document.location).submit()

$(document).on 'page:change', ->
  App.Explore.init()
