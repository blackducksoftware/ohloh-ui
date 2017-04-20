class App.TypeAhead
  constructor: (domElement) ->
    @element = $(domElement)
    @source = @element.data('source')
    @selectHandlerName = @element.data('select')
#   The attribute below are for fields that grab information
#   based on a preceding form field. Example positions#new
#   field must contain a prerequisiteInput data attribute to work
    @prerequisiteInput = @element.data('prerequisiteInput')

  setup: ->
    @element.autocomplete
      source: @source
      select: (e, ui) => @[@selectHandlerName](ui) if @selectHandlerName
    if @prerequisiteInput then prerequisiteInput(@element, @source)

  prerequisiteInput = (element, source) ->
#   If mulitiple fields contain a prerequisiteInput tag another
#   conditional can be added to accommodate that particular field.
    if source is '/autocompletes/contributions'
      element.autocomplete
        source: (request, response) ->
          $.ajax({
            dataType: "json",
            url: '/autocompletes/contributions',
            data: "term=#{$('#position_committer_name').val()}&project= #{$('#position_project_oss').val()}",
            success: response
          });

  submitForm: (ui) ->
    @element.val(ui.item.value)
    @element.parents('form.autocomplete-submit').submit()

  submitFormWithId: (ui) ->
    @element.val(ui.item.id)
    @element.parents('form.autocomplete-submit').submit()

  duplicatesSelect: (ui) ->
    $('#duplicate_good_project_id').val(ui.item.id)
    project_url = "#{$('a#good_project_url').attr('base')}/#{ui.item.id}"
    $('a#good_project_url').attr('href', project_url).text(project_url)
    $('#good_project_url_label').removeClass('hidden')

  new_manager: (ui) ->
    $('#account_id').val(ui.item.id)

class App.ChosenSelect
  constructor: () ->
    $('.chzn-select').chosen()
    $('#sort_by .chzn-search').hide()
    $('.nav-select-container .chzn-search').show()
    $('.value-select').chosen()

$(document).ready ->
  new App.ChosenSelect
  $('.autocompletable').each ->
    autocomplete = new App.TypeAhead($(this))
    autocomplete.setup()
