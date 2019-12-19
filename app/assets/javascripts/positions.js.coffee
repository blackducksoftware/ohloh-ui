$(document).on 'page:change', ->
  if $('#position_form').length
    new App.OrganizationSelector('position')
    new SetupProjectAndLanguagesSections
    new SetupNestedProjectExperienceFields
    new SetupCommitDateRadioBindings

class SetupNestedProjectExperienceFields
  constructor: ->
    @$form = $('#project-experience-form')
    @$addNewButton = $('#add-project-experience')
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
    $container.find('input').autocomplete({ source: '/autocompletes/project' })
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
      $('#project-experience-form').find('input').autocomplete({ source: '/autocompletes/project' })
    $('a.expanded').click ->
      $('#additional-fields').addClass('hidden')
      $(this).addClass('hidden')
      $('a.collapsed').removeClass('hidden')

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
