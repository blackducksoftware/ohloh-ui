CompareProjects =
  init: () ->
    $('.projects_compare input.proj').autocomplete
      source: '/autocompletes/project'
      select: (e, ui) ->
        $(this).val(ui.item.value)
        if $("#auto_submit").val() != 'false'
          $(this).parents('form:first').submit()
    $(".projects_compare .graph").click(CompareProjects.graph)

  graph: () ->
    tb_show('Project Comparison Graph', $(this).attr('graph'), false)
    return false

$ ->
  CompareProjects.init()
