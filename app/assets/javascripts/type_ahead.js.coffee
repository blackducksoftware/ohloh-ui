class App.TypeAhead
  constructor: (domElement) ->
    @element = $(domElement)
    @source = @element.data('source')
    @selectHandlerName = @element.data('select')

  setup: ->
    @element.autocomplete
      source: @source
      select: (e, ui) => @[@selectHandlerName](ui) if @selectHandlerName

  submitForm: (ui) ->
    @element.val(ui.item.value)
    @element.parents('form.autocomplete-submit').submit()

  duplicatesSelect: (ui) ->
    $('#duplicate_good_project_id').val(ui.item.id)
    project_url = "#{$('a#good_project_url').attr('base')}/#{ui.item.id}"
    $('a#good_project_url').attr('href', project_url).text(project_url)
    $('#good_project_url_label').removeClass('hidden')

class App.ChosenSelect
  constructor: () ->
    $('.chzn-select').chosen()
    $('#sort_by .chzn-search').hide()
    $('.nav-select-container .chzn-search').show()
    $('.value-select').chosen()

$(document).on 'page:change', ->
  new App.ChosenSelect
  $('.autocompletable').each ->
    autocomplete = new App.TypeAhead($(this))
    autocomplete.setup()
