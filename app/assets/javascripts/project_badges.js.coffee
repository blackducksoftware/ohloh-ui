ProjectNewBadge =
  init: () ->
    debugger
    this.initializeNewBadge(this)
    this.handleEvents(this)

  initializeNewBadge: (_klass) ->


  handleEvents: (_klass) ->
    $('#project_badges_page').on 'change', '#select_project_badge', (event) ->


$(document).on 'page:change', ->
  ProjectNewBadge.init()
