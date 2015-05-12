$ ->
  if $('#position_form').length
    new App.OrganizationSelector('position')
    new SetupAutocompletes
    new SetupProjectAndLanguagesSections
    new SetupNestedProjectExperienceFields
    new SetupCommitDateRadioBindings

  if $('#positions-index-page').length
    new ToggleProjectDescriptionExpansion

class SetupNestedProjectExperienceFields
  constructor: ->
    @$form = $('#project-experience-form')
    @$addNewButton = $('#add-project-experience')
    setupAutocomplete(@$form.find('.autocompletable'))
    @setupNestedInputBindings()

  setupNestedInputBindings: ->
    @$addNewButton.click =>
      $lastInput = @$form.find('input.autocompletable').last()
      $lastInputContainer = $lastInput.parent()
      $newInputContainer = cloneFrom($lastInputContainer)
      $newInput = $newInputContainer.find('input')
      incrementNumericAttributes($newInput, $lastInput)
      $lastInputContainer.after($newInputContainer)
      setupDynamicInputBindings($newInputContainer)

    @$form.find('.remove').click(markExistingInputForDestruction)

  setupAutocomplete = ($input) ->
    $input.autocomplete(source: '/autocompletes/project')

  markExistingInputForDestruction = ->
    $parent = $(this).parent()
    $input = $parent.find('input.autocompletable')
    $input.val('')
    # Persisted nested association will have a hidden field for id.
    if $parent.next('input').length
      name = $input.attr('name').match(/^(.+)\[.+?\]$/)[1]
      deletableName = "#{ name }[_destroy]"
      $input.attr('name', deletableName)
      $input.val(true)
      $parent.hide()

  setupDynamicInputBindings = ($container) ->
    setupAutocomplete($container.find('input'))
    $container.find('.remove').click =>
      $container.remove()

  incrementNumericAttributes = ($newInput, $lastInput) ->
    newId = incrementNumber($lastInput.attr('id'))
    $newInput.attr('id', newId)
    newName = incrementNumber($lastInput.attr('name'))
    $newInput.attr('name', newName)

  cloneFrom = ($lastInputContainer) ->
    $newInputContainer = $lastInputContainer.clone()
    $newInputContainer.find('input').val('')
    $newInputContainer

  incrementNumber = (string) ->
    id = Number(string.match(/\d+/))
    incrementedId = id + 1
    string.replace(/\d+/, incrementedId)

class SetupProjectAndLanguagesSections
  constructor: ->
    $('a.collapsed').click ->
      $('#additional-fields').removeClass('hidden')
      $(this).addClass('hidden')
      $('a.expanded').removeClass('hidden')
    $('a.expanded').click ->
      $('#additional-fields').addClass('hidden')
      $(this).addClass('hidden')
      $('a.collapsed').removeClass('hidden')

class SetupAutocompletes
  constructor: ->
    $('#position_project_oss').autocomplete source: '/autocompletes/project'
    ### FIXME: Integrate after implementing contributions#autocomplete.
    $('#position_committer_name').autocomplete source: (request, response) ->
      $.getJSON '/autocompletes/contributors', {
        term: request.term
        project: ->
          $('#position_project_oss').val()
      }, response
    ###

class SetupCommitDateRadioBindings
  constructor: ->
    clearDateOnChoosingAutomatic()
    chooseManualOnSettingDate()

  clearDateOnChoosingAutomatic = ->
    $('.choose-automatic').click ->
      $selectorParent = $(this).parent().find('.chosen')
      clearSelectedOption($selectorParent.find("select[id$='date_1i']"))
      clearSelectedOption($selectorParent.find("select[id$='date_2i']"))

  chooseManualOnSettingDate = ->
    $('#position_start_date_1i').change ->
      $('#manual-start-date').click()

    $('#position_start_date_2i').change ->
      $('#manual-start-date').click()

    $('#position_stop_date_1i').change ->
      $('#manual-stop-date').click()

    $('#position_stop_date_2i').change ->
      $('#manual-stop-date').click()

  clearSelectedOption = ($element) ->
    $element.find('option').first().prop('selected', true)
    $element.trigger('liszt:updated')

class ToggleProjectDescriptionExpansion
  constructor: ->
    $('a[id^=more_desc_], a[id^=less_desc_]').click ->
      $parent = $(this).parent()
      $parent.toggleClass('hidden')
      $parent.siblings('.one-project-description').toggleClass('hidden')
