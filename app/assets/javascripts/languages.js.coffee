App.Languages =
  init: ->
    $('.last_language').change App.Languages.add_language

  add_language: ->
    $parent = $(this).parent('.language')
    $clone = $parent.clone(true)
    $clone.insertAfter($parent)
    $(this).removeClass('last_language')
    $(this).unbind('change')
    $parent.removeClass('language')

    $clone.find('.chzn-container').remove()
    $clone.find('select').removeClass('chzn-done').chosen()

$(document).on 'page:change', ->
  App.Languages.init()

